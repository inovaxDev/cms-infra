terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "google_sql_database_instance" "cms_db_instance" {
  name             = "cms-db-instance"
  database_version = "MYSQL_5_7"
  region           = var.region
  deletion_protection = false

  settings {
    tier = "db-n1-standard-1"
  }
}
