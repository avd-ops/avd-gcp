terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

resource "google_compute_resource_policy" "schedule" {
  count   = var.enable_instance_schedule ? 1 : 0
  project = var.project_id
  name    = "sched-avd-hosts-${var.environment}"
  region  = var.region

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.start_cron_schedule
    }
    vm_stop_schedule {
      schedule = var.stop_cron_schedule
    }
    time_zone = var.schedule_time_zone
  }
}

resource "google_compute_instance_template" "session_host" {
  project      = var.project_id
  name_prefix  = "tpl-avd-hybrid-${var.environment}-"
  machine_type = var.machine_type
  region       = var.region
  tags         = ["avd-session-host"]

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

  resource_policies = var.enable_instance_schedule ? [google_compute_resource_policy.schedule[0].id] : []

  metadata = {
    enable-oslogin             = "FALSE"
    avd-arc-resource-group     = var.arc_resource_group
    avd-host-pool-name         = var.host_pool_name
    avd-identity-mode          = "entra-joined"
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
    max_unavailable_fixed        = 1
    instance_redistribution_type = "PROACTIVE"
  }
}
