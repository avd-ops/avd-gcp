terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

resource "google_compute_network" "avd" {
  project                 = var.project_id
  name                    = "vpc-avd-hybrid-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hosts" {
  project                  = var.project_id
  name                     = "snet-avd-hosts-${var.environment}"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.avd.id
  private_ip_google_access = true
}

resource "google_compute_router" "nat" {
  count   = var.egress_mode == "cloud-nat" ? 1 : 0
  project = var.project_id
  name    = "cr-avd-hybrid-${var.environment}"
  region  = var.region
  network = google_compute_network.avd.id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.egress_mode == "cloud-nat" ? 1 : 0
  project                            = var.project_id
  name                               = "nat-avd-hybrid-${var.environment}"
  router                             = google_compute_router.nat[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.hosts.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "deny_internet_rdp" {
  project   = var.project_id
  name      = "fw-avd-deny-rdp-${var.environment}"
  network   = google_compute_network.avd.id
  direction = "INGRESS"
  priority  = 100

  deny {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["avd-session-host"]
}

resource "google_compute_firewall" "allow_egress_avd_arc" {
  project   = var.project_id
  name      = "fw-avd-allow-egress-${var.environment}"
  network   = google_compute_network.avd.id
  direction = "EGRESS"
  priority  = 900

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  dynamic "allow" {
    for_each = var.enable_rdp_shortpath_udp_3478 ? [1] : []
    content {
      protocol = "udp"
      ports    = ["3478"]
    }
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["avd-session-host"]
}
