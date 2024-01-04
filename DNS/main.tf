terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

data "google_container_cluster" "cms_gke_cluster_data" {
  name = var.cluster_name
}

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}

resource "google_dns_record_set" "vault_dns_record" {
  name         = "vault-cms.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [var.ingress_controller_ip]
}
