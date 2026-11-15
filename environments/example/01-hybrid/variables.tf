variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment (dev, test, prod)."
}

variable "profile" {
  type        = string
  default     = "lab"
  description = "Cost/guardrail profile (lab or enterprise)."
  validation {
    condition     = contains(["lab", "enterprise"], var.profile)
    error_message = "profile must be lab or enterprise."
  }
}

variable "subnet_cidr" {
  type    = string
  default = "10.20.0.0/24"
}

variable "egress_mode" {
  type    = string
  default = "cloud-nat"
}

variable "enable_rdp_shortpath_udp_3478" {
  type    = bool
  default = true
}

variable "enable_fslogix_netapp" {
  type    = bool
  default = false
}

variable "machine_type" {
  type    = string
  default = "n2-standard-4"
}

variable "source_image" {
  type        = string
  description = "Packer golden image self-link or family for Windows 11 Enterprise."
}

variable "session_host_count" {
  type    = number
  default = 1
}

variable "arc_resource_group" {
  type        = string
  description = "Azure Resource Group for Arc-enabled servers."
}

variable "host_pool_name" {
  type        = string
  description = "Azure AVD Hybrid host pool name."
}

variable "region_zone_count" {
  type        = number
  default     = 4
  description = "Number of zones in the target GCP region for Regional MIG surge policy."
}

variable "arc_sp_secret_id" {
  type        = string
  default     = ""
  description = "Optional GCP Secret Manager secret ID holding the scoped Azure Arc onboarding SP secret."
}

variable "startup_script_ps1" {
  type        = string
  default     = ""
  description = "PowerShell startup script content for Entra join and Azure Arc onboarding."
}
