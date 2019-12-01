provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}

resource "google_compute_instance" "production" {
 name         = "production"
 machine_type = var.machine_type
 zone         = var.zone
 tags         = ["prod-8081-8083", "http-server"]

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  metadata = {
    ssh-keys = "jenkins:${file(var.public_key_path)}"
  }

  network_interface {
    network = var.network
    network_ip = var.network_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "mongo-db" {
 name         = "mongo-db"
 machine_type = var.machine_type
 zone         = var.zone
 tags         = ["http-server", "elk"]

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  metadata = {
    ssh-keys = "jenkins:${file(var.public_key_path)}"
  }
  
  network_interface {
    network = var.network
    network_ip = var.network_ip
    access_config {
    }
  }
}

resource "google_compute_firewall" "prod-8081-8083" {
  name    = "prod-8081-8083"
  network = var.network

  target_tags = ["prod-8081-8083"]

  allow {
    protocol = "tcp"
    ports    = ["8081-8083"]
  }
}

resource "google_compute_firewall" "elk" {
  name    = "elk"
  network = var.network

  target_tags = ["elk"]

  allow {
    protocol = "tcp"
    ports    = ["5601"]
  }
}