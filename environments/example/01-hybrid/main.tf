terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "../../../modules/network"

  project_id                    = var.project_id
  region                        = var.region
  environment                   = var.environment
  subnet_cidr                   = var.subnet_cidr
  egress_mode                   = var.egress_mode
  enable_rdp_shortpath_udp_3478 = var.enable_rdp_shortpath_udp_3478
}

module "storage" {
  source = "../../../modules/storage"

  project_id            = var.project_id
  region                = var.region
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  enable_fslogix_netapp = var.enable_fslogix_netapp
}

module "compute" {
  source = "../../../modules/compute"

  project_id               = var.project_id
  region                   = var.region
  environment              = var.environment
  subnet_id                = module.network.subnet_id
  machine_type             = var.machine_type
  source_image             = var.source_image
  session_host_count       = var.session_host_count
  arc_resource_group       = var.arc_resource_group
  host_pool_name           = var.host_pool_name
  enable_instance_schedule = var.enable_instance_schedule
}
