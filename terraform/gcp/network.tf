provider "google" {
  project = var.project_id
  region  = var.region
}  

# Create a VPC
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false  # We will create our own subnets
}

#------------------------------------------------------------------

# Create a Public Subnet (for Load Balancer or NAT Gateway)
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
}

#------------------------------------------------------------------

# Create a Private Subnet (for Kubernetes & Backend VMs)
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  network                  = google_compute_network.vpc_network.id
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  private_ip_google_access = true  # Allows VMs in this subnet to access Google APIs (e.g., Cloud SQL)

  # ✅ Add Secondary IP Ranges for Kubernetes
  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.0.96.0/20" # have 4096ip, Expand the range to allow more IPs
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.0.120.0/24" # have 256ip
  }
}

#------------------------------------------------------------------

# Firewall Rule: Allow internal traffic within VPC
resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/16"]
}


# Firewall Rule: Allow SSH access from anywhere (for testing, but should be restricted)
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # CHANGE THIS TO YOUR IP FOR SECURITY!
}

#------------------------------------------------------------------

# Create a Cloud Router
resource "google_compute_router" "cloud_router" {
  name    = "cloud-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}


# Create a Cloud NAT (Allows private subnet VMs to access the internet)
resource "google_compute_router_nat" "cloud_nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.cloud_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
