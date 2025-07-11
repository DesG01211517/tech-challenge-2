terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "TechC2-User"
}

# ----------------------
# VPC Module
# ----------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "tech-challenge-2-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "Tech Challenge 2"
  }
}

# ----------------------
# EKS Module
# ----------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "tech-challenge-2-cluster"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    node_group = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Project = "Tech Challenge 2"
  }
}

# ----------------------
# ECR Repository for Docker images
# ----------------------
resource "aws_ecr_repository" "tech_challenge_repo" {
  name = "tech-challenge-2-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "Tech Challenge 2"
  }
}














