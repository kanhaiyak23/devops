terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ── NOTE: ECR repo is created/ensured by the CI pipeline (AWS CLI step).
# ── We reference it purely via var.ecr_registry_url + var.app_name.
# ── No data source = no AWS lookup during plan/apply = truly idempotent.

# ── LabRole — AWS Academy pre-existing role (cannot create IAM roles) ────────
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# ── Auto-fetch default VPC (no manual VPC ID secret needed) ──────────────────
data "aws_vpc" "default" {
  default = true
}

# ── Auto-fetch 2 public subnets in different AZs (ALB requires 2 AZs) ────────
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# ── Auto-fetch default security group ────────────────────────────────────────
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# ── S3 Bucket (required: unique name, versioning, encryption, public-block) ──
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.app_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name      = "${var.app_name}-bucket"
    ManagedBy = "terraform"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_public_access" {
  bucket                  = aws_s3_bucket.app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── ALB Security Group ───────────────────────────────────────────────────────
resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow HTTP inbound to ALB from internet"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.app_name}-alb-sg"
    ManagedBy = "terraform"
  }
}

# ── Application Load Balancer ─────────────────────────────────────────────────
resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name      = "${var.app_name}-alb"
    ManagedBy = "terraform"
  }
}

# ── Target Group (type=ip required for Fargate awsvpc mode) ───────────────────
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.app_name}-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    port                = "5001"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name      = "${var.app_name}-tg"
    ManagedBy = "terraform"
  }
}

# ── ALB Listener — port 80 → target group ────────────────────────────────────
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ── ECS Cluster ──────────────────────────────────────────────────────────────
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name      = "${var.app_name}-cluster"
    ManagedBy = "terraform"
  }
}

# ── CloudWatch Log Group ─────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7

  tags = {
    Name      = "${var.app_name}-logs"
    ManagedBy = "terraform"
  }
}

# ── ECS Task Definition ──────────────────────────────────────────────────────
resource "aws_ecs_task_definition" "app_task" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.image_uri
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name      = "${var.app_name}-task"
    ManagedBy = "terraform"
  }
}

# ── ECS Service ──────────────────────────────────────────────────────────────
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  # Wire ECS tasks into the ALB target group
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.app_name
    container_port   = 5001
  }

  # Grace period so the container can start before ALB health checks begin
  health_check_grace_period_seconds = 60

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  # ALB listener must exist before service registers tasks
  depends_on = [aws_lb_listener.app_listener]

  tags = {
    Name      = "${var.app_name}-service"
    ManagedBy = "terraform"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
