terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

resource "google_netapp_storage_pool" "fslogix" {
  count         = var.enable_fslogix_netapp ? 1 : 0
  project       = var.project_id
  name          = "np-avd-fslogix-${var.environment}"
  location      = var.region
  service_level = var.netapp_service_level
  capacity_gib  = var.pool_capacity_gib
  network       = var.vpc_id
}

resource "google_netapp_volume" "fslogix" {
  count        = var.enable_fslogix_netapp ? 1 : 0
  project      = var.project_id
  location     = var.region
  name         = "vol-avd-fslogix-${var.environment}"
  capacity_gib = var.volume_capacity_gib
  share_name   = "fslogix-profiles"
  storage_pool = google_netapp_storage_pool.fslogix[0].name
  protocols    = ["SMB"]
}
