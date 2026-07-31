terraform {
  backend "s3" {
    bucket         = "dhoni-demo-terraform-bucket-123456"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}        
