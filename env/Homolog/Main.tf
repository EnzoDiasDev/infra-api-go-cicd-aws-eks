module "prod" {
    source = "../../infra"
    
    cluster_name = "homolog2"
}

output "IP_db" {
  value = module.prod.IP
}

# Lidos pelo workflow de deploy para criar os Secrets do Kubernetes.
output "db_secret_arn" {
  value = module.prod.db_secret_arn
}

output "api_keys_secret_arn" {
  value = module.prod.api_keys_secret_arn
}
