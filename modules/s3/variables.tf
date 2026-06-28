variable "bucket_name" {
  description = "Globally-unique S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/uat/prod) — used for tagging"
  type        = string
}

variable "force_destroy" {
  description = "Allow deleting a non-empty bucket (keep false for prod)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags to merge onto the bucket"
  type        = map(string)
  default     = {}
}
