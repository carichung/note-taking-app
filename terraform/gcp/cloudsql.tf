# for 1st time connect database to your private_network, you need enable a special service called "Service Networking API", and create a private service connection between VPC <-> cloud SQL internal network, otherwise there will be error after "terraform apply"
# check what api did you enable - $gcloud services list --enabled


# Reserve an IP range for Cloud SQL to use inside your VPC
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "cloudsql-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  address       = "10.10.0.0"  # ✅ Far from existing ranges
  network       = google_compute_network.vpc_network.id
}

# Enable the private service access connection between your VPC and Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# enable google API - gcloud services enable servicenetworking.googleapis.com


#---------------------------------------------------------------------------------------


resource "google_sql_database_instance" "postgres_instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    disk_size = 20
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id #connect to private network
    }
  }

  deletion_protection = false

  # 👇 Ensure the private service connection is ready first
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

}

resource "google_sql_user" "postgres_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}
