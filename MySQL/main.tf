terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

data "google_compute_network" "default_net" {
  name = "default"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "cms-db-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_net.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.default_net.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "cms_db_instance" {
  name                = "cms-db-instance"
  database_version    = "MYSQL_5_7"
  region              = var.region
  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-n1-standard-1"

    ip_configuration {
      ipv4_enabled                                  = true
      private_network                               = data.google_compute_network.default_net.id
      enable_private_path_for_google_cloud_services = true
    }
  }
}
