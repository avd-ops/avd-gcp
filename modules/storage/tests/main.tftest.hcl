mock_provider "google" {}

run "storage_disabled_by_default" {
  command = plan

  variables {
    project_id  = "avd-gcp-lab-placeholder"
    region      = "us-central1"
    environment = "dev"
    vpc_id      = "projects/avd-gcp-lab-placeholder/global/networks/vpc-avd-hybrid-dev"
  }

  assert {
    condition     = length(google_netapp_storage_pool.fslogix) == 0
    error_message = "NetApp storage pool must not be created when enable_fslogix_netapp is false."
  }
}

run "storage_enabled" {
  command = plan

  variables {
    project_id            = "avd-gcp-lab-placeholder"
    region                = "us-central1"
    environment           = "prod"
    vpc_id                = "projects/avd-gcp-lab-placeholder/global/networks/vpc-avd-hybrid-prod"
    enable_fslogix_netapp = true
  }

  assert {
    condition     = length(google_netapp_volume.fslogix) == 1
    error_message = "NetApp SMB volume should be created when enable_fslogix_netapp is true."
  }
}
