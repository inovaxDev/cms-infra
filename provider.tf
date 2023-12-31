provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

data "google_container_cluster" "gke_cluster" {
  name       = var.cluster_name
  depends_on = [module.GKE_module]
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  token = data.google_client_config.provider.access_token

  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    token = data.google_client_config.provider.access_token

    host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}
