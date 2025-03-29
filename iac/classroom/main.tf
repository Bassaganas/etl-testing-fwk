provider "aws" {
  region = "eu-west-1"
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = "lambda-classroom-management-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    "Environment" = "Classroom"
  }
}

# IAM Policy for Lambda to manage classroom resources
resource "aws_iam_role_policy" "lambda_classroom_policy" {
  name = "LambdaClassroomManagementPolicy"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:GetUser",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListUsers",
          "iam:ListAccessKeys",
          "iam:PutUserPolicy",
          "iam:AttachUserPolicy",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "iam:*",
          "tag:*",
          "resource-groups:*",
          "organizations:*",
          "servicecatalog:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# S3 Bucket to store the Classroom Management Lambda
resource "aws_s3_bucket" "lambda_classroom_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    "Environment" = "Classroom"
  }
}

resource "aws_s3_object" "upload_lambda_classroom" {
  bucket = aws_s3_bucket.lambda_classroom_bucket.bucket
  key    = "lambda_classroom.zip"
  source = "${path.root}/../../lambda_packages/lambda_classroom.zip"
  acl    = "private"
}

# Lambda Function to manage classrooms
resource "aws_lambda_function" "classroom_management_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  s3_bucket     = aws_s3_bucket.lambda_classroom_bucket.bucket
  s3_key        = "lambda_classroom.zip"

  memory_size = 256
  timeout     = 300

  tags = {
    "Environment" = "Classroom"
  }

  depends_on = [
    aws_iam_role.lambda_role,
    aws_s3_bucket.lambda_classroom_bucket
  ]
}

# Lambda Function URL for classroom management
resource "aws_lambda_function_url" "classroom_management_url" {
  function_name      = aws_lambda_function.classroom_management_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive", "content-type"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

# Outputs
output "lambda_function_arn" {
  value = aws_lambda_function.classroom_management_lambda.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lambda_classroom_bucket.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.lambda_classroom_bucket.arn
}

output "lambda_function_url" {
  value = aws_lambda_function_url.classroom_management_url.function_url
} 
