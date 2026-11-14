variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region for subnet and Cloud NAT."
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, prod)."
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "subnet_cidr" {
  type        = string
  default     = "10.20.0.0/24"
  description = "CIDR range for the AVD session-host subnet."
}

variable "egress_mode" {
  type        = string
  default     = "cloud-nat"
  description = "Outbound internet egress mode (cloud-nat or direct-vpc)."
  validation {
    condition     = contains(["cloud-nat", "direct-vpc"], var.egress_mode)
    error_message = "egress_mode must be cloud-nat or direct-vpc."
  }
}

variable "enable_rdp_shortpath_udp_3478" {
  type        = bool
  default     = true
  description = "Allow outbound UDP 3478 for RDP Shortpath TURN/STUN relays."
}
