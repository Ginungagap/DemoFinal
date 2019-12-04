// provider "google" {
//   credentials = var.credentials
//   project     = var.project
//   region      = var.region
// }

// resource "google_compute_instance" "production" {
//  name         = "production"
//  machine_type = var.machine_type
//  zone         = var.zone
//  tags         = ["prod-8081-8083", "http-server"]

//   boot_disk {
//     initialize_params {
//       image = var.disk_image
//     }
//   }

//   metadata = {
//     ssh-keys = "jenkins:${file(var.public_key_path)}"
//   }

//   network_interface {
//     network = var.network
//     network_ip = var.network_ip
//     access_config {
//     }
//   }
// }

// resource "google_compute_instance" "mongo-db" {
//  name         = "mongo-db"
//  machine_type = var.machine_type
//  zone         = var.zone
//  tags         = ["http-server", "elk"]

//   boot_disk {
//     initialize_params {
//       image = var.disk_image
//     }
//   }

//   metadata = {
//     ssh-keys = "jenkins:${file(var.public_key_path)}"
//   }
  
//   network_interface {
//     network = var.network
//     network_ip = var.network_ip
//     access_config {
//     }
//   }
// }

// resource "google_compute_firewall" "prod-8081-8083" {
//   name    = "prod-8081-8083"
//   network = var.network

//   target_tags = ["prod-8081-8083"]

//   allow {
//     protocol = "tcp"
//     ports    = ["8081-8083"]
//   }
// }

// resource "google_compute_firewall" "elk" {
//   name    = "elk"
//   network = var.network

//   target_tags = ["elk"]

//   allow {
//     protocol = "tcp"
//     ports    = ["5601"]
//   }
// }

provider "google" {
  credentials = "project-for-terraform.json"
  project     = var.project
  region      = var.region
}

resource "google_container_cluster" "standard-cluster-1" {
  name     = "demo-cluster"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}