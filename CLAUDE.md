@AGENTS.md

# avd-gcp

GCP compute, network, FSLogix storage, and Azure Arc onboarding control plane for AVD Hybrid.

## Key constraints

- AVD Hybrid supports single-session Windows 10/11 Enterprise or Windows Server 2016–2025;
  Windows 10/11 Enterprise multi-session is unsupported.
- MVP targets single-session Windows 11 Enterprise + Entra ID join (no AD DS required).
- AVD Autoscale, Start VM on Connect, and Azure power management are unsupported on Hybrid;
  use GCP Compute Instance Schedules (`google_compute_resource_policy`).
- All Terraform tests must run offline with `mock_provider "google" {}` (`terraform test`).
