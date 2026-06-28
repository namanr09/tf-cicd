terraform {
  backend "s3" {
    bucket         = "tf-cicd-tfstate-323146837002"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-cicd-tflock"
    encrypt        = true
  }
}
