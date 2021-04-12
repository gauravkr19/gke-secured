provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name-prefix       = "secured"
  location          = var.regional ? var.region : var.zones[0]
  region            = var.regional ? var.region : join("-", slice(split("-", var.zones[0]), 0, 2))
  zone_count        = length(var.zones)

  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{ 
    cidr_blocks : var.master_authorized_networks 
    }]
  
  master_version_regional = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version
  master_version_zonal    = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.zone.latest_master_version
  master_version   = var.regional ? local.master_version_regional : local.master_version_zonal
}

data "google_container_engine_versions" "region" {
  location       = local.location
  project  = var.project_id
}

data "google_container_engine_versions" "zone" {
  // Work around to prevent a lack of zone declaration from causing regional cluster creation from erroring out due to error
  //
  //     data.google_container_engine_versions.zone: Cannot determine zone: set in this resource, or set provider-level zone.
  //
  location = local.zone_count == 0 ? data.google_compute_zones.available.names[0] : var.zones[0]
  project  = var.project_id
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = local.region
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 2
}

resource "random_id" "suffix" {
  byte_length = 4
}

/*
resource "google_project_service" "project" {
  project = "var.project_id"
  service = "container.googleapis.com"

  disable_dependent_services = true
}
*/