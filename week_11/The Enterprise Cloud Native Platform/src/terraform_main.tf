# 1. Configuración del Proveedor
provider "aws" {
  region = "eu-west-1"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "eu-west-1"]
      command     = "aws"
    }
  }
}

# 2. VPC Segura (Con subredes de Base de Datos)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "production-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]
  
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_dns_hostnames         = true
}

# 3. AWS EKS Cluster (Adaptado al Free Tier y Access Entries)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "prod-cluster"
  cluster_version = "1.33"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = false
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    general = {
      desired_size   = 3
      min_size       = 2
      max_size       = 4
      instance_types = ["t3.micro"] 
    }
  }
}

# 4. RDS (PostgreSQL Free Tier compatible)
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier           = "prod-db"
  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t3.micro"
  
  allocated_storage           = 20
  manage_master_user_password = true
  username                    = "dbadmin"

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
}

# 5. Instalación Automática de ArgoCD (A dieta y sin esperas)
resource "helm_release" "argocd" {
  depends_on       = [module.eks]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"

  timeout         = 900
  cleanup_on_fail = true
  wait            = false

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "dex.enabled"
      value = "false"
    },
    {
      name  = "notifications.enabled"
      value = "false"
    }
  ]
}