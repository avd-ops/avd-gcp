output "fslogix_storage_mode" {
  value = var.enable_fslogix_netapp ? "gcp-netapp-volumes" : "disabled"
}

output "volume_name" {
  value = var.enable_fslogix_netapp ? google_netapp_volume.fslogix[0].name : ""
}
