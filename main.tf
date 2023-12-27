module "DNS_module" {
  source = "./DNS"
  providers = {
    google = google
  }

  depends_on = [module.GKE_module]

  # Variables
  dns_zone_name = var.dns_zone_name
  cluster_name  = var.cluster_name
}

module "GKE_module" {
  source = "./GKE"
  providers = {
    google = google
  }

  # Variables
  region       = var.region
  cluster_name = var.cluster_name
}

module "SQL_module" {
  source = "./MySQL"
  providers = {
    google = google
  }

  # Variables
  region = var.region
}

# TODO: Colocar o Vault dentro do cluster mesmo

# module "Vault_module" {
#   source = "./Vault"
#   providers = {
#     google = google
#   }

#   # Variables
#   project = var.project
#   svc_account_email = var.svc_account_email
# }

module "k8s_module" {
  source = "./Kubernetes"
  providers = {
    kubernetes = kubernetes
    helm = helm
  }

  # Variables
}