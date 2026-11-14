output "c32_gcp_outputs" {
  description = "Contract C32 (avd-gcp-outputs/v1) payload for avd-azure, avd-landing-zone, and avd-current-state."
  value = {
    schema              = "avd-gcp-outputs/v1"
    environment         = var.environment
    region              = var.region
    profile             = var.profile
    osFamily            = "windows-11-enterprise"
    identityMode        = "entra-joined"
    vpcName             = module.network.vpc_name
    subnetName          = module.network.subnet_name
    egressMode          = var.egress_mode
    rdpShortpathUdp3478 = var.enable_rdp_shortpath_udp_3478
    fslogixStorageMode  = module.storage.fslogix_storage_mode
    instanceGroupName   = module.compute.instance_group_name
    sessionHostCount    = var.session_host_count
    arcResourceGroup    = var.arc_resource_group
    hostPoolName        = var.host_pool_name
  }
}
