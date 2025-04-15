# Reference your reserved global IP (34.54.111.7)
data "google_compute_global_address" "cdn_ip" {
  name = "frontend-cdn-ip"  # This must match what you named it in GCP
}

# Google-managed SSL certificate for the frontend domain
resource "google_compute_managed_ssl_certificate" "cdn_cert" {
  name = "cdn-ssl-cert"

  managed {
    domains = ["cdn.notes.carichung.com"]
  }
}

# GCS bucket for hosting the frontend (React build)
resource "google_storage_bucket" "cdn_bucket" {
  name     = "cdn-notes-carichung-com"
  location = "ASIA"
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

# Make the GCS bucket public
resource "google_storage_bucket_iam_binding" "cdn_public_access" {
  bucket = google_storage_bucket.cdn_bucket.name

  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# Backend bucket (used by the load balancer)
resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "cdn-backend-bucket"
  bucket_name = google_storage_bucket.cdn_bucket.name
  enable_cdn  = true
}

# URL map to route traffic for cdn.notes.carichung.com
resource "google_compute_url_map" "cdn_url_map" {
  name            = "cdn-url-map"
  default_service = google_compute_backend_bucket.cdn_backend.id

  host_rule {
    hosts        = ["cdn.notes.carichung.com"]
    path_matcher = "cdn-path-matcher"
  }

  path_matcher {
    name            = "cdn-path-matcher"
    default_service = google_compute_backend_bucket.cdn_backend.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.cdn_backend.id
    }
  }
}

# HTTPS proxy
resource "google_compute_target_https_proxy" "cdn_https_proxy" {
  name             = "cdn-https-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_cert.id]
  url_map          = google_compute_url_map.cdn_url_map.id
}

# Forwarding rule using your new static IP
resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule" {
  name                  = "cdn-https-forwarding-rule"
  ip_address            = data.google_compute_global_address.cdn_ip.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.cdn_https_proxy.id
  load_balancing_scheme = "EXTERNAL"
}

