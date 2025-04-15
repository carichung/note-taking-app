resource "google_container_cluster" "gke_cluster" {
  name     = "private-gke-cluster"
  location = var.region
  network  = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.private_subnet.id

  deletion_protection = false  # Allow easy deletion via Terraform


#-----------------------------------------------------------------------------


  # Private cluster settings
  private_cluster_config {
    enable_private_nodes    = true   # Ensures worker nodes are private
    enable_private_endpoint = false  # API server accessible only from private network
    master_ipv4_cidr_block = "172.16.0.0/28"  # Reserved IP range for Kubernetes API
  }

  # Enable IP Aliases for better networking
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods-range"
    services_secondary_range_name = "gke-services-range"
  }

  # Add networking configurations
  networking_mode = "VPC_NATIVE"


#-----------------------------------------------------------------------------


  # Auto-scaling settings for worker nodes
   node_pool {
    name       = "default-pool"
    initial_node_count = 1  #change to initial i/o fixed node count

    autoscaling {
      min_node_count = 1
      max_node_count = 3
    }

    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 20
      image_type   = "COS_CONTAINERD"

      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }
  }


#-----------------------------------------------------------------------------


  # Enable logging & monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}
