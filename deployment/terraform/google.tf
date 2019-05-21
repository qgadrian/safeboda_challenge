provider "google" {
  # must create a service account first
  # then, generate a json creds file
  credentials = "${file("safe-boda.json")}"
  project     = "safe-boda"
  region      = "us-east1"
  zone        = "us-east1-b"
}

resource "google_compute_network" "default" {
  name                    = "safe-boda-network"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "default" {
  name   = "safe-boda-subnetwork"
  region = "us-east1"
  network = "${google_compute_network.default.self_link}"
  ip_cidr_range = "10.23.5.0/24"
}

resource "google_compute_firewall" "default" {
  name    = "safe-boda-firewall"
  network = "${google_compute_network.default.self_link}"

  allow {
    protocol = "icmp"
  }

  # epdm port and friends for clustering
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "4000", "4369", "14000",  "24000"]
  }
}

resource "google_compute_instance" "safe-boda-0" {
    depends_on = [
      "google_compute_network.default",
    ]

    name = "safe-boda-0"
    zone = "us-east1-b"
    machine_type = "f1-micro"

    boot_disk {
      initialize_params {
        image = "centos-cloud/centos-7"
        type = "pd-standard"
        size = 20
      }
    }

    network_interface {
      subnetwork = "${google_compute_subnetwork.default.self_link}"

      access_config {
        // Ephemeral IP
      }
    }

    metadata {
      sshKeys = "qgadrian:${file("/Users/adrian/.ssh/id_rsa.pub")}"
    }
}

resource "google_compute_instance" "safe-boda-1" {
    depends_on = [
      "google_compute_network.default",
    ]

    name = "safe-boda-1"
    zone = "us-east1-b"
    machine_type = "f1-micro"

    boot_disk {
      initialize_params {
        image = "centos-cloud/centos-7"
        type = "pd-standard"
        size = 20
      }
    }

    network_interface {
      subnetwork = "${google_compute_subnetwork.default.self_link}"

      access_config {
        // Ephemeral IP
      }
    }
}
