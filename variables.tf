variable "project" {
  description = "ID do projeto no GCP"
}

variable "region" {
  description = "Região do GCP onde o cluster será criado"
}

variable "credentials_file" {
  description = "Caminho para o arquivo de credenciais do GCP"
}

variable "dns_zone_name" {
 description = "Nome da Cloud DNS zone"
}

variable "svc_account_email" {
  description = "E-mail que será referenciado"
}

variable "cluster_name" {
  description = "Nome do cluster"
}

variable "letsencrypt_email" {
  description = "LetsEncrypt Email"
}

variable "vault_server_domain" {
  description = "Vault Server Domain"
}

variable "ingress_controller_ip" {
  description = "Ingress Controller IP"
}
