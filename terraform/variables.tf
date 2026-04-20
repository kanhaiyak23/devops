variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name — must match APP_NAME in the workflow (set via TF_VAR_app_name)"
  type        = string
  default     = "devops-static-app"
}

variable "ecr_registry_url" {
  description = "ECR registry base URL (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com). Set via TF_VAR_ecr_registry_url in workflow."
  type        = string
}

variable "image_uri" {
  description = "Full ECR image URI to deploy (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:sha). Set via TF_VAR_image_uri in workflow."
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID for ECS task (set via TF_VAR_subnet_id secret)"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for ECS task (set via TF_VAR_security_group_id secret)"
  type        = string
}
