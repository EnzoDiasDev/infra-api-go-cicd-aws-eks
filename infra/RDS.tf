resource "aws_db_instance" "default" {
  allocated_storage    = 20 # mínimo aceito pelo RDS PostgreSQL (10 é recusado)
  db_name              = "root"
  engine               = "postgres"
  engine_version       = "17" # fixa a versão principal para combinar com o parameter group abaixo
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "rootroot"
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name = aws_db_parameter_group.postgres.name
}

# A partir do Postgres 15, o RDS exige SSL por padrão (rds.force_ssl = 1).
# A API conecta com "sslmode=disable", então sem isto o banco recusa a conexão.
resource "aws_db_parameter_group" "postgres" {
  name   = "${var.cluster_name}-postgres17-sem-ssl"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

output "IP" {
  value = aws_db_instance.default.address
}
