terraform {
  backend "s3" {
    bucket  = "terraform-state-classroom-management"
    key     = "classroom/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
} 
