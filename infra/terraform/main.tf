terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecr_repository" "backend" {
  name                 = "ecommerce-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "ecommerce-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "ecommerce-vpc"
  cidr = "10.0.0.0/16"

  # 1. Define your 3 Availability Zones
  azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  # 2. Mirror the Public Tier (Frontend)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # 3. Mirror the Private Tiers (Backend & Postgres)
  # We use 101-103 for App, and 201-203 for Data
  private_subnets = [
    "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", # App Tier (Backend)
    "10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"  # Data Tier (Postgres)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Project = "ecommerce"
  } 
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "ecommerce-eks"
  cluster_version = "1.29"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access  = true  # Enables connection from your laptop
  cluster_endpoint_private_access = true  # Enables communication from worker nodes

  # Required for ALB Controller later
  enable_irsa = true

  eks_managed_node_groups = {
  t4g_nodes = {
    name = "t4g-node-group"
    
    ami_type = "AL2023_ARM_64_STANDARD"
    
    instance_types = ["t4g.medium"]

    min_size     = 2
    max_size     = 5
    desired_size = 3 

    capacity_type = "ON_DEMAND"

    # gp3 for better performance
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 20
          volume_type           = "gp3"
          delete_on_termination = true

     #Gives nodes permission to manage EBS volumes
     iam_role_additional_policies = {
       ebs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
         
         }
        }
      }
    }
  }
}
  #listens for PVC requests and creates AWS EBS volumes.
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}
  
  tags = {
    Project = "ecommerce"
    Managed = "terraform"
  }  
   
}
