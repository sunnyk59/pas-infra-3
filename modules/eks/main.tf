  
# VPC Module
module "vpc" {
  source = "../vpc"
}

 
# Define the namespace variable
variable "namespace_name" {
  description = "The name of the namespace for the hospital"
  type        = string
}

# Define the namespace variable
variable "environment_name" {
  description = "Environment (Staging or Production)"
  type        = string
}

# Kubernetes provider configuration
provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_name    = "webpas-eks-cluster"
  cluster_version = "1.27"
  cluster_endpoint_public_access = true
  kms_key_enable_default_policy = false
  vpc_id = module.vpc.vpc_id

  # Worker nodes should only use public subnets
  subnet_ids = [
    module.vpc.private_subnet_1,
    module.vpc.private_subnet_2
  ]

  # Control plane should only use private subnets
  control_plane_subnet_ids = [
    module.vpc.private_subnet_1,
    module.vpc.private_subnet_2
  ]

  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3.medium"]
    }
  }
}

# Create the namespace using the passed variable
resource "kubernetes_namespace" "namespace" {
  provider = kubernetes.eks

  metadata {
    name   = var.namespace_name  # Use the variable here
    labels = {
      environment = var.environment_name
      hospital    = var.namespace_name
    }
  }
}

# IAM Role for Node Group (as before)
resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Role Policy Attachments (as before)
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Outputs
output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.eks.token
}

# Data source to get the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}
