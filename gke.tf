# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "gkecluster-${lower(random_id.suffix.hex)}"
  location = local.location

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  enable_shielded_nodes       = var.enable_shielded_nodes
  enable_binary_authorization = var.enable_binary_authorization
  
  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }
  
  pod_security_policy_config {
    enabled = var.pod_security_policy_enabled
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  addons_config {
    http_load_balancing {
      disabled = ! var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = ! var.horizontal_pod_autoscaling
    }

    network_policy_config {
      disabled = ! var.network_policy
    }
  }
  
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range.1.range_name
  } 
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "nodepool-${lower(random_id.suffix.hex)}"
  location   = local.location
  project    = var.project_id
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = local.name-prefix
    }

    preemptible  = true
    image_type   = "COS"
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${local.name-prefix}-gke"]
    
    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }
}
