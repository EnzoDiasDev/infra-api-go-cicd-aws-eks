resource "aws_security_group" "ssh_cluster" {
  name        = "ssh_cluster"
  vpc_id      = module.vpc.vpc_id
}

# Exceção aceita na varredura de IaC: SSH aberto nos nós. Pendência registrada
# no SSDLC, fase 2 (SSH liberado para 0.0.0.0/0). Ao remover esta regra, apague
# também o comentário de ignore.
#trivy:ignore:AWS-0107
resource "aws_security_group_rule" "ssh_cluster_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #0.0.0.0 - 255.255.255.255
  security_group_id = aws_security_group.ssh_cluster.id
}

# Exceção aceita na varredura de IaC: os nós precisam sair para a internet
# para baixar imagens e falar com a API do EKS.
#trivy:ignore:AWS-0104
resource "aws_security_group_rule" "ssh_cluster_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #0.0.0.0 - 255.255.255.255
  security_group_id = aws_security_group.ssh_cluster.id
}

# O banco não tem regra de saída: o security group é stateful, então as
# respostas às conexões recebidas saem sem precisar de regra de egress.
resource "aws_security_group" "db" {
  name        = "db_ECS"
  vpc_id      = module.vpc.vpc_id
}

# A porta do banco só aceita conexões de dentro da VPC (onde estão os nós e os
# pods). Antes estava aberta para a internet inteira (0.0.0.0/0).
resource "aws_security_group_rule" "tcp_db" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.db.id
}
