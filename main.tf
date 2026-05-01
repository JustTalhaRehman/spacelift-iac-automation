terraform {
  required_version = ">= 1.5.0"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.14.0"
    }
  }

  # This root stack manages itself — it's the administrative stack
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "spacelift/administrative/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "spacelift" {
  # Reads SPACELIFT_API_KEY_ID and SPACELIFT_API_KEY_SECRET from environment
}
