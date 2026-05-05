variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name — must match APP_NAME in the workflow (set via TF_VAR_app_name)"
  type        = string
  default     = "devops-static123456789-app"
}

variable "ecr_registry_url" {
  description = "ECR registry base URL (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com). Set via TF_VAR_ecr_registry_url in workflow."
  type        = string
}

variable "image_uri" {
  description = "Full ECR image URI to deploy (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:sha). Set via TF_VAR_image_uri in workflow."
  type        = string
}
# ── NOTE: vpc_id, subnet_id, subnet_id_2, security_group_id are no longer
# ── variables — Terraform auto-fetches them via data sources in main.tf.
