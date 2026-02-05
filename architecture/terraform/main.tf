resource "aws_s3_bucket" "loan_s3" {
  bucket = "loan-reports"
}

resource "aws_lambda_function" "loan_lambda" {
  function_name = "loan_container_function"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.loan_ecr.repository_url}:latest"
  image_config {
    entry_point = ["/lambda-entrypoint.sh"]
    command     = ["app.handler"]
  }
  memory_size = 512
  timeout     = 30
  architectures = ["arm64"]
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}


resource "aws_ecr_repository" "loan_ecr" {
  name                 = "personal_loan"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}