terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }

  required_version = ">= 1.10.0"
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", "us-east-1"]
    command     = "aws"
  }
}

# "kubernetes_service" foi substituído por "kubernetes_service_v1" (mesmo recurso: um Service do tipo LoadBalancer)
resource "kubernetes_service_v1" "LoadBalancer" {
  metadata {
    name = "load-balancer-go-api"
  }
  spec {
    selector = {
      nome = "go"
    }
    port {
      port = 8000
      target_port = 8000
    }
    type = "LoadBalancer"
  }

  # Só cria o Service depois do cluster e das permissões de acesso estarem prontos
  depends_on = [module.eks]
}
