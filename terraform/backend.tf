# terraform/backend.tf
# Configuration du remote state (S3 + DynamoDB) pour gérer l'état Terraform de manière collaborative et sécurisée.

terraform {
  backend "s3" {
    bucket         = "techshop-terraform-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "techshop-terraform-state-locks"
  }
}
