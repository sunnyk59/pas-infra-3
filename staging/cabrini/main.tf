
module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source = "../../modules/eks"
}

module "namespace" {
  source         = "../../modules/namespace"
  namespace_name = "cabrini-namespace"
  environment    = "prod"
  hospital_name  = "cabrini"
 
  depends_on = [module.vpc,module.eks]  
}
