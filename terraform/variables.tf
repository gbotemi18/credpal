variable "project_name" {
  type        = string
  description = "Name prefix for AWS resources"
  default     = "credpal-assessment"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "Public domain for ACM + ALB listener (e.g. app.example.com)"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID for domain validation + ALB alias"
}

variable "container_image" {
  type        = string
  description = "Container image URI (e.g. ghcr.io/ORG/REPO/credpal-assessment:latest)"
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 3000
}

variable "desired_count" {
  type        = number
  description = "Number of tasks"
  default     = 2
}

variable "cpu" {
  type        = number
  description = "Fargate CPU units"
  default     = 256
}

variable "memory" {
  type        = number
  description = "Fargate memory (MiB)"
  default     = 512
}
