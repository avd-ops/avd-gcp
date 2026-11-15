terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

resource "google_service_account" "session_host" {
  project      = var.project_id
  account_id   = "sa-avd-hosts-${var.environment}"
  display_name = "AVD Hybrid Session Host (${var.environment})"
}

resource "google_secret_manager_secret_iam_member" "arc_sp_secret" {
  count     = var.arc_sp_secret_id != "" ? 1 : 0
  project   = var.project_id
  secret_id = var.arc_sp_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.session_host.email}"
}

resource "google_compute_instance_template" "session_host" {
  project      = var.project_id
  name_prefix  = "tpl-avd-hybrid-${var.environment}-"
  machine_type = var.machine_type
  region       = var.region
  tags         = ["avd-session-host"]

  service_account {
    email  = google_service_account.session_host.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-ssd"
    disk_size_gb = var.boot_disk_size_gb
  }

  network_interface {
    subnetwork = var.subnet_id
    # No external IP: outbound traffic routes through Cloud NAT
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Note: GCP does not support attaching google_compute_resource_policy instance schedules
  # to Regional MIG instance templates; use Cloud Scheduler / MIG target_size or standby policies.

  metadata = {
    enable-oslogin             = "FALSE"
    avd-arc-resource-group     = var.arc_resource_group
    avd-host-pool-name         = var.host_pool_name
    avd-identity-mode          = "entra-joined"
    avd-arc-sp-secret-id       = var.arc_sp_secret_id
    windows-startup-script-ps1 = var.startup_script_ps1
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "session_hosts" {
  project            = var.project_id
  name               = "mig-avd-hosts-${var.environment}"
  region             = var.region
  base_instance_name = "avdh-${var.environment}"
  target_size        = var.session_host_count

  version {
    instance_template = google_compute_instance_template.session_host.id
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_unavailable_fixed        = 0
    max_surge_fixed              = var.region_zone_count
    instance_redistribution_type = "PROACTIVE"
  }
}
