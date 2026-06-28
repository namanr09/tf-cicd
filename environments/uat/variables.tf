variable "region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "force_destroy" {
  description = "Allow deleting non-empty buckets (true for non-prod, false for prod)"
  type        = bool
  default     = false
}

