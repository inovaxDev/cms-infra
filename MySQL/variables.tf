variable "region" {
  description = "Região do GCP onde o cluster será criado"
}

variable "prem_ips" {
  type = list(string)
  description = "On premise Ips List"
}
