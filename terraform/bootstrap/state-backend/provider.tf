provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "cloud-infrastructure-foundation"
      Component = "terraform-state"
      ManagedBy = "Terraform"
    }
  }
}
