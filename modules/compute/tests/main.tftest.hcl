mock_provider "google" {}

run "compute_shielded_mig_plan" {
  command = plan

  variables {
    project_id         = "avd-gcp-lab-placeholder"
    region             = "us-central1"
    environment        = "dev"
    subnet_id          = "projects/avd-gcp-lab-placeholder/regions/us-central1/subnetworks/snet-avd-hosts-dev"
    source_image       = "projects/avd-gcp-lab-placeholder/global/images/family/avd-win11-ent"
    arc_resource_group = "rg-avd-arc-dev"
    host_pool_name     = "hp-avd-hybrid-dev"
    session_host_count = 2
  }

  assert {
    condition     = google_compute_region_instance_group_manager.session_hosts.name == "mig-avd-hosts-dev"
    error_message = "MIG name should follow mig-avd-hosts-<env>."
  }

  assert {
    condition     = google_compute_instance_template.session_host.shielded_instance_config[0].enable_secure_boot == true
    error_message = "Shielded VM Secure Boot must be enabled."
  }

  assert {
    condition     = length(google_compute_resource_policy.schedule) == 1
    error_message = "Instance schedule should be created by default to avoid idle burn."
  }

  assert {
    condition     = google_service_account.session_host.account_id == "sa-avd-hosts-dev"
    error_message = "Dedicated least-privilege service account must be created for session hosts."
  }
}
