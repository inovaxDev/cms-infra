variable "project" {
  description = "ID do projeto no GCP"
}

variable "email" {
  description = "Email LetsEncrypt"
}

variable "domain" {
  description = "Domínio do Vault Server"
}

variable "svc_account_email" {
  description = "E-mail que será referenciado"
}

variable "ingress_controller_ip" {
  description = "Ingress Controller IP"
}