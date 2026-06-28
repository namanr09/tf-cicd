variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Path to the directory containing the function code"
  type        = string
}

variable "handler" {
  description = "Entrypoint, e.g. index.handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory in MB"
  type        = number
  default     = 128
}

variable "environment_vars" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "additional_policy_json" {
  description = "Optional extra IAM policy (JSON) for accessing other AWS resources"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention (controls cost)"
  type        = number
  default     = 14
}

variable "tags" {
  type    = map(string)
  default = {}
}
