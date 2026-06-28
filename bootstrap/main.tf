terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "tf-cicd-tfstate-323146837002"
    key     = "bootstrap/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "github_repo" {
  description = "The owner/repo allowed to assume the CI role"
  type        = string
}

# 1. Register GitHub as a trusted OIDC identity provider in your account
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Trust policy: only tokens from YOUR repo may assume this role
data "aws_iam_policy_document" "ci_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Scope to your repo (any branch/PR/env for now; we'll tighten prod later)
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "tf-cicd-github-actions"
  assume_role_policy = data.aws_iam_policy_document.ci_trust.json
}

# 3. Permissions the pipeline needs.
#    PowerUser = all services EXCEPT IAM. We add scoped IAM separately below.
resource "aws_iam_role_policy_attachment" "poweruser" {
  role       = aws_iam_role.ci.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Scoped IAM: only manage roles that belong to THIS project (least privilege)
data "aws_iam_policy_document" "ci_iam" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:PassRole",
      "iam:AttachRolePolicy", "iam:DetachRolePolicy",
      "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy",
      "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
      "iam:TagRole", "iam:UntagRole",
    ]
    resources = ["arn:aws:iam::*:role/tf-cicd-*"]
  }
}

resource "aws_iam_role_policy" "ci_iam" {
  name   = "tf-cicd-iam-management"
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.ci_iam.json
}

output "ci_role_arn" {
  description = "Put this ARN in GitHub as a secret/variable for the workflow"
  value       = aws_iam_role.ci.arn
}
