terraform {
  backend "s3" {
    # Mesmo bucket da infra do ECS, mas com outra "key": cada projeto tem seu próprio state.
    bucket = "terraform-state-api-go-cicd-enzodiasdev"
    key    = "EKS/Homolog/terraform.tfstate"
    region = "us-east-1"

    # Trava nativa do S3 (Terraform >= 1.10): impede dois applies ao mesmo tempo.
    use_lockfile = true
  }
}
