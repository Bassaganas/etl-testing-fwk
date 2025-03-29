variable "s3_bucket_name" {
  description = "Name of the S3 bucket where the Lambda function will be stored"
  type        = string
  default     = "lambda-classroom-management-dev"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function for classroom management"
  type        = string
  default     = "classroom-management"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "classroom-admin"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
} 
