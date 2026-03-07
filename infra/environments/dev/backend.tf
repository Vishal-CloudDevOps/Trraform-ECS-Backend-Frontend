terraform {
  backend "s3" {
    bucket = "vishal-terraform-statefile"
    key    = "ecs-rds/dev/terraform.tfstate"
    region = "ap-south-1"
    #dynamodb_table = "terraform-locks"
    #encrypt        = true
  }
}