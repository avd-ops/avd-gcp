mock_provider "google" {}

run "hybrid_root_c32_plan" {
  command = plan

  variables {
    project_id         = "avd-gcp-lab-placeholder"
    region             = "us-central1"
    environment        = "dev"
    profile            = "lab"
    source_image       = "projects/avd-gcp-lab-placeholder/global/images/family/avd-win11-ent"
    session_host_count = 1
    arc_resource_group = "rg-avd-arc-dev"
    host_pool_name     = "hp-avd-hybrid-dev"
    arc_sp_secret_id   = "arc-sp-secret-dev"
  }

  assert {
    condition     = output.c32_gcp_outputs.schema == "avd-gcp-outputs/v1"
    error_message = "Output schema must match C32 avd-gcp-outputs/v1."
  }

  assert {
    condition     = output.c32_gcp_outputs.fslogixStorageMode == "disabled"
    error_message = "Lab profile default should keep NetApp Volumes disabled."
  }

  assert {
    condition     = module.compute.instance_group_name == "mig-avd-hosts-dev"
    error_message = "Compute module should expose instance_group_name for the 01-hybrid environment."
  }
}
