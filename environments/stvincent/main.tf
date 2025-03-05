
module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source = "../../modules/eks"
}

module "namespace" {
  source         = "../../modules/namespace"
  namespace_name = "stvincent-namespace"
  environment    = "prod"
  hospital_name  = "stvincent"
 
  depends_on = [module.vpc,module.eks]  
}
