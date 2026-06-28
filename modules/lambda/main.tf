# Zip the source code automatically at plan/apply time
data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

# Trust policy: let the Lambda service assume this role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Baseline: permission to write CloudWatch logs
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Optional: extra permissions (e.g. write to S3 / put to Firehose)
resource "aws_iam_role_policy" "additional" {
  count  = var.additional_policy_json == null ? 0 : 1
  name   = "${var.function_name}-additional"
  role   = aws_iam_role.this.id
  policy = var.additional_policy_json
}

# Explicit log group so retention (and cost) is controlled
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  environment {
    variables = var.environment_vars
  }

  tags       = var.tags
  depends_on = [aws_cloudwatch_log_group.this, time_sleep.role_propagation]
}

resource "time_sleep" "role_propagation" {
  depends_on      = [aws_iam_role.this, aws_iam_role_policy_attachment.basic]
  create_duration = "10s"
}
