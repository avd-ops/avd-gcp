packer {
  required_version = ">= 1.10.0"
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1.1.0"
    }
  }
}

variable "project_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "image_family" {
  type    = string
  default = "avd-win11-ent"
}

variable "source_image_family" {
  type        = string
  description = "Imported BYOL Windows 11 Enterprise image family in GCP (windows-cloud only publishes Windows Server; see docs/image-pipeline.md)."
}

source "googlecompute" "avd_win11" {
  project_id          = var.project_id
  zone                = var.zone
  source_image_family = var.source_image_family
  image_family        = var.image_family
  image_name          = "avd-win11-ent-${formatdate("YYYYMMDDhhmm", timestamp())}"
  machine_type        = "n2-standard-4"
  disk_size           = 128
  disk_type           = "pd-ssd"
  communicator        = "winrm"
  winrm_username      = "packer_admin"
  winrm_use_ssl       = true
  winrm_insecure      = true
  enable_secure_boot  = true
  enable_vtpm         = true
  enable_integrity_monitoring = true

  metadata = {
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user packer_admin /add & net localgroup administrators packer_admin /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
}

build {
  sources = ["source.googlecompute.avd_win11"]

  provisioner "powershell" {
    inline = [
      "Write-Output 'Pre-staging FSLogix and Azure Connected Machine Agent prerequisites for AVD Hybrid on GCP.'",
      "Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'C:\\Windows\\Temp\\FSLogixAppsSetup.zip'",
      "Invoke-WebRequest -Uri 'https://aka.ms/AzureConnectedMachineAgent' -OutFile 'C:\\Windows\\Temp\\AzureConnectedMachineAgent.msi'"
    ]
  }
}
