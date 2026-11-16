module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Na v21 do módulo: cluster_name -> name, cluster_version -> kubernetes_version,
  # cluster_endpoint_public_access -> endpoint_public_access
  name                   = var.cluster_name
  kubernetes_version     = "1.34" # a 1.24 não é mais suportada pelo EKS
  endpoint_public_access = true

  # Desde a v20, quem cria o cluster NÃO vira admin automaticamente.
  # Sem isto, o Terraform (provider kubernetes) e o kubectl recebem "Unauthorized".
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    alura = {
      min_size     = 1
      max_size     = 10
      desired_size = 3
      vpc_security_group_ids = [aws_security_group.ssh_cluster.id]
      # t2.micro (1 GB, até 4 pods por nó) não comporta os pods do sistema + a API.
      # t3.small é a menor opção que funciona de forma estável no EKS.
      instance_types = ["t3.small"]
    }
  }
}
