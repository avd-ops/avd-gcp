mock_provider "google" {}

run "network_cloud_nat_defaults" {
  command = plan

  variables {
    project_id  = "avd-gcp-lab-placeholder"
    region      = "us-central1"
    environment = "dev"
  }

  assert {
    condition     = google_compute_network.avd.name == "vpc-avd-hybrid-dev"
    error_message = "VPC name should follow vpc-avd-hybrid-<env>."
  }

  assert {
    condition     = length(google_compute_router_nat.nat) == 1
    error_message = "Cloud NAT should be created when egress_mode is cloud-nat."
  }
}
