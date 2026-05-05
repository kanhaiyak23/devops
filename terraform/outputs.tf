output "s3_bucket_name" {
  description = "S3 bucket name (unique: app_name + account_id)"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "alb_dns_name" {
  description = "ALB DNS name — visit http://<this value> in your browser"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "ALB ARN — used for import step"
  value       = aws_lb.app_alb.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL (computed from registry + app_name)"
  value       = "${var.ecr_registry_url}/${var.app_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.app_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app_service.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.app_task.arn
}

output "lab_role_arn" {
  description = "AWS Academy LabRole ARN used as ECS task execution role"
  value       = data.aws_iam_role.lab_role.arn
}
