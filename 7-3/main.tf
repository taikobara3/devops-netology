terraform {

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "nl-bucket05071917"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = ""
    secret_key = ""

    skip_region_validation      = true
    skip_credentials_validation = true
  }

  required_version = ">= 0.13"
}

locals {
  instances = {
  stage = 1
  prod   = 2
  }
}

provider "yandex" {
  zone = "ru-central1-b"
}

resource "yandex_compute_instance" "nln" {

  name = "nl-${count.index}"

  count = local.instances[terraform.workspace]

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ch5n0oe99ktf1tu8r"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

locals {
  ids = toset([
    "one",
    "two",
  ])
}

resource "yandex_compute_instance" "nld" {

  name = "nld-${each.key}"

  for_each = local.ids

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ch5n0oe99ktf1tu8r"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

