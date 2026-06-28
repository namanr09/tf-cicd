# Your AWS account ID, used to make the bucket name globally unique
data "aws_caller_identity" "current" {}

module "data_bucket" {
  source = "../../modules/s3"

  bucket_name   = "${var.project}-${var.environment}-data-${data.aws_caller_identity.current.account_id}"
  environment   = var.environment
  force_destroy = true # fine for dev; we'll set false for prod
}

output "bucket_arn" {
  description = "ARN of the data bucket"
  value       = module.data_bucket.bucket_arn
}
