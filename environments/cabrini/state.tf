
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.41.0" 
    }
  }
  backend "s3" {
    bucket         = "webpas-terraform-state-cabrini"
    key            = "terraform/environments/cabrini/terraform.tfstate"  
    region         = "ap-southeast-2"
    dynamodb_table = "webpas-terraform-state-lock"
    encrypt        = true
  }
}