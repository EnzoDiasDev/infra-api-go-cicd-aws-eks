module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "VPC-EKS"
  cidr = "10.0.0.0/16" #10.0.1.1 - 10.0.255.255

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets= ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # Os nós do EKS ficam nas subnets públicas: sem IP público eles não alcançam
  # o cluster nem o Docker Hub e nunca entram no cluster.
  map_public_ip_on_launch = true

  # Tags que o Kubernetes usa para saber onde criar o load balancer do Service
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
}
