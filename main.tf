provider "google" {
  credentials = file("Openshift-21b31bd54421.json")
  project     = "openshift-281007"
  region      = "europe-west4"
}

resource "google_compute_network" "vpc_network" {
  name                    = "openshift-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "openshift-subnet1"
  ip_cidr_range = "192.168.122.0/24"
  region        = "europe-west4"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "fw-rule1" {
  name      = "common-rules"
  network   = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "fw-rule2" {
  name      = "subnet-rules"
  network   = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["192.168.122.0/24"]
}

resource "google_compute_firewall" "fw-rule3" {
  name      = "master-rules"
  network   = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8443", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = [ "master" ]
}

resource "google_compute_disk" "docker_volume" {
  name  = "openshift-disk"
  size  = 20
  zone  = "europe-west4-a"
}

resource "google_compute_instance" "master" {
  name         = "master"
  machine_type = "n1-standard-4"
  zone         = "europe-west4-a"
  allow_stopping_for_update = true
  tags = [ "master" ]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  attached_disk {
    source = google_compute_disk.docker_volume.id
  }

  metadata = {
    ssh-keys = "ansible:${file("./ssh-certs/id_rsa.pub")}"
  }

  network_interface {
    subnetwork       = google_compute_subnetwork.subnet1.id
    network_ip       = "192.168.122.100"
    access_config {
    }
  }

  provisioner "file" {
    source = "ssh-certs/id_rsa"
    destination = "~ansible/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~ansible/.ssh/id_rsa"
    ]
  }

  connection {
    type     = "ssh"
    host = self.network_interface.0.access_config.0.nat_ip
    private_key = file("./ssh-certs/id_rsa")
    user = "ansible"
  }
}

resource "google_compute_instance" "nodes" {
  count = 2
  name         = "node${count.index+1}"
  machine_type = "n1-standard-2"
  zone         = "europe-west4-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys = "ansible:${file("ssh-certs/id_rsa.pub")}"
  }

  network_interface {
    subnetwork       = google_compute_subnetwork.subnet1.id
    network_ip       = "192.168.122.10${count.index+1}"
    access_config {
    }
  }
}

output "public_ip" {
  value = google_compute_instance.master.network_interface.0.access_config.0.nat_ip
}
