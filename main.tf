module "DNS_module" {
  source = "./DNS"
  providers = {
    google = google
  }

  depends_on = [module.GKE_module]

  # Variables
  dns_zone_name         = var.dns_zone_name
  cluster_name          = var.cluster_name
  ingress_controller_ip = var.ingress_controller_ip
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

  depends_on = [module.GKE_module]

  # Variables
  region   = var.region
  prem_ips = [var.ingress_controller_ip]
}

module "Vault_module" {
  source = "./Vault"
  providers = {
    google     = google
    kubernetes = kubernetes
  }

  depends_on = [module.k8s_module]

  # Variables
  project               = var.project
  svc_account_email     = var.svc_account_email
  email                 = var.letsencrypt_email
  domain                = var.vault_server_domain
  ingress_controller_ip = var.ingress_controller_ip
}

module "k8s_module" {
  source = "./Kubernetes"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.GKE_module]

  # Variables
  region = var.region
}
