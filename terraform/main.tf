module "vpc_main" {
  source     = "./modules/vpc"
  tags       = local.tags
  cidr_block = "10.0.0.0/16"
}

module "subnet_1a" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc_main.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"
  depends_on        = [module.vpc_main]
}

module "subnet_1b" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc_main.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "sa-east-1b"
  depends_on        = [module.vpc_main]
}

module "route_table_main" {
  source = "./modules/route_table"
  vpc_id = module.vpc_main.vpc_id
  tags   = local.tags

  routes = [
    { cidr_block = module.subnet_1a.cidr_block },
    { cidr_block = module.subnet_1b.cidr_block }
  ]

  subnet_ids = [
    module.subnet_1a.subnet_id,
    module.subnet_1b.subnet_id
  ]

  depends_on = [
    module.vpc_main,
    module.subnet_1a,
    module.subnet_1b,
  ]
}

module "ec2-1a" {
  source = "./modules/ec2"
  tags = local.tags
  availability_zone = "sa-east-1a"
  ami = "ami-0a6db7d09c3037d6c"
  #security_group = ""
  subnet_id = module.subnet_1a.subnet_id
  instance_type = "t2.micro"
  depends_on = [ 
    module.subnet_1a
   ]
}

module "ec2-1b" {
  source = "./modules/ec2"
  tags = local.tags
  availability_zone = "sa-east-1a"
  ami = "ami-0a6db7d09c3037d6c"
  #security_group = ""
  subnet_id = module.subnet_1a.subnet_id
  instance_type = "t2.micro"
  depends_on = [ 
    module.subnet_1b
   ]
}

