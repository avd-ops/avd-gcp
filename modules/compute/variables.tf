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
  description = "PowerShell startup script content for Entra join and Azure Arc + CloudDeviceExtension onboarding."
}

variable "enable_instance_schedule" {
  type        = bool
  default     = true
  description = "Attach a GCP Compute Instance Schedule to stop hosts outside active hours."
}

variable "start_cron_schedule" {
  type        = string
  default     = "0 7 * * 1-5"
  description = "Cron schedule to start session hosts (weekdays 07:00)."
}

variable "stop_cron_schedule" {
  type        = string
  default     = "0 19 * * 1-5"
  description = "Cron schedule to stop session hosts (weekdays 19:00)."
}

variable "schedule_time_zone" {
  type        = string
  default     = "America/New_York"
  description = "IANA time zone for the Compute Instance Schedule."
}

variable "arc_sp_secret_id" {
  type        = string
  default     = ""
  description = "Optional GCP Secret Manager secret ID holding the scoped Azure Arc onboarding SP secret."
}
