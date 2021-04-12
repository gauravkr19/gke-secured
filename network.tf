# VPC
resource "google_compute_network" "vpc" {
  name                    = "${local.name-prefix}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.name-prefix}-subnet"
  region        = var.netregion
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_subnet_nodes

  secondary_ip_range {
    range_name    = "${local.name-prefix}-pod-cidr"
    ip_cidr_range = var.ip_cidr_subnet_pods
  }

  secondary_ip_range {
    range_name    = "${local.name-prefix}-service-cidr"
    ip_cidr_range = var.ip_cidr_subnet_nodes_services
  }  
}

variable "netregion" {
  description = "region"
  default = "us-central1"
}


# Firewall for Bastion
resource "google_compute_firewall" "default" {
  name    = "${local.name-prefix}-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}




