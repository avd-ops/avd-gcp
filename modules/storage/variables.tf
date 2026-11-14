variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region for NetApp Volumes."
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, prod)."
}

variable "vpc_id" {
  type        = string
  description = "Self-link or ID of the VPC attached to NetApp Volumes."
}

variable "enable_fslogix_netapp" {
  type        = bool
  default     = false
  description = "Deploy Google Cloud NetApp Volumes (SMB) for FSLogix. Default false to avoid idle lab spend."
}

variable "netapp_service_level" {
  type        = string
  default     = "STANDARD"
  description = "NetApp Volumes service level (STANDARD, PREMIUM, EXTREME)."
  validation {
    condition     = contains(["STANDARD", "PREMIUM", "EXTREME"], var.netapp_service_level)
    error_message = "netapp_service_level must be STANDARD, PREMIUM, or EXTREME."
  }
}

variable "pool_capacity_gib" {
  type        = number
  default     = 2048
  description = "Storage pool capacity in GiB (minimum 2048 GiB for STANDARD)."
}

variable "volume_capacity_gib" {
  type        = number
  default     = 100
  description = "FSLogix SMB volume capacity in GiB."
}
