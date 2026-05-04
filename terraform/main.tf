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
    subnets          = [var.subnet_id]
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  tags = {
    Name      = "${var.app_name}-service"
    ManagedBy = "terraform"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
