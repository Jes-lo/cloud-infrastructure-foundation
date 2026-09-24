module "network" {
  source = "../../modules/network"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
}
module "access" {
  source = "../../modules/access"

  project_name           = var.project_name
  environment            = var.environment
  private_subnet_id      = module.network.private_subnet_id
  eice_security_group_id = module.security.eice_security_group_id
}
module "compute" {
  source = "../../modules/compute"

  project_name               = var.project_name
  environment                = var.environment
  private_subnet_id          = module.network.private_subnet_id
  workload_security_group_id = module.security.workload_security_group_id
}
