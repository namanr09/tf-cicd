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
# Build an IAM policy that lets the function write to OUR bucket
data "aws_iam_policy_document" "ingest_permissions" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${module.data_bucket.bucket_arn}/*"]
  }
}

module "ingest_fn" {
  source = "../../modules/lambda"

  function_name = "${var.project}-${var.environment}-ingest"
  source_dir    = "${path.module}/../../src/ingest"
  handler       = "index.handler"

  environment_vars = {
    BUCKET_NAME = module.data_bucket.bucket_id
  }

  additional_policy_json   = data.aws_iam_policy_document.ingest_permissions.json
  attach_additional_policy = true
}

output "ingest_function_name" {
  value = module.ingest_fn.function_name
}
