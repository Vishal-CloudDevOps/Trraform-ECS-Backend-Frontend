module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.project_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  
  enable_dns_support   = true
  enable_dns_hostnames = true

    # 🔑 Pinpointed change: disable NAT gateway creation
  enable_nat_gateway = false
  single_nat_gateway = false

  #disable VPN gateway if you don’t need it
  enable_vpn_gateway = false
}
