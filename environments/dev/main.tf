provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../../modules/network"

  env      = var.env
  vpc_cidr = var.vpc_cidr
}

module "ec2" {
  source = "../../modules/compute"

  env                = var.env
  my_ip              = var.my_ip
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}
