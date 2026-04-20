variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for all resource names"
  type        = string
  default     = "devops-static12345678-app"
}

variable "image_uri" {
  description = "Full ECR image URI to deploy (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:sha)"
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID for ECS task network (passed via TF_VAR_subnet_id secret)"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for ECS task (passed via TF_VAR_security_group_id secret)"
  type        = string
}
