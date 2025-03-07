

module "eks" {
  source          = "../../modules/eks"
  namespace_name  = "cabrini-namespace"  # Pass the namespace name here
  environment_name = "staging" 
}




