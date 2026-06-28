output "bucket_id" {
  description = "The bucket name"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The bucket ARN — consumed by firehose, lambda IAM, etc."
  value       = aws_s3_bucket.this.arn
}
