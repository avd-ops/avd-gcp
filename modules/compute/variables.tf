variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region for the Managed Instance Group."
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, prod)."
}

variable "subnet_id" {
  type        = string
  description = "VPC subnetwork self-link."
}

variable "machine_type" {
  type        = string
  default     = "n2-standard-4"
  description = "Compute Engine machine type for single-session Windows 11 hosts."
}

variable "source_image" {
  type        = string
  description = "Packer golden image self-link or family for Windows 11 Enterprise."
}

variable "boot_disk_size_gb" {
  type        = number
  default     = 128
  description = "OS boot disk size in GiB."
}

variable "session_host_count" {
  type        = number
  default     = 1
  description = "Target number of AVD Hybrid session hosts in the MIG."
}

variable "region_zone_count" {
  type        = number
  default     = 4
  description = "Number of zones in the target GCP region (Regional MIG max_surge_fixed must be >= zone count when max_unavailable_fixed = 0)."
  validation {
    condition     = var.region_zone_count >= 1
    error_message = "region_zone_count must be at least 1."
  }
}

variable "arc_resource_group" {
  type        = string
  description = "Azure Resource Group name for Azure Arc-enabled servers."
}

variable "host_pool_name" {
  type        = string
  description = "Azure AVD Hybrid host pool name."
}

variable "startup_script_ps1" {
  type        = string
  default     = ""
  description = "PowerShell startup script content for Entra join and Azure Arc onboarding."
}

variable "arc_sp_secret_id" {
  type        = string
  default     = ""
  description = "Optional GCP Secret Manager secret ID holding the scoped Azure Arc onboarding SP secret."
}
