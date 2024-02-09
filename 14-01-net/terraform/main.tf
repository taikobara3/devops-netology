# Объявление пользовательских переменных

variable "folder_id" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "vm_user_nat" {
  type = string
}

variable "ssh_key_path" {
  type = string
}

# Объявление прочих переменных

locals {
  network_name     = "netology"
  subnet_name1     = "public"
  subnet_name2     = "privat"
  sg_nat_name      = "nat-instance-sg"
  public-vm        = "public-vm"
  private-vm       = "private-vm"
  vm_nat_name      = "nat-instance"
  route_table_name = "nat-instance-route"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-b" # Зона доступности по умолчанию
}

# Создание сетей

resource "yandex_vpc_network" "netology" {
  name = "netology"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.netology.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.netology.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

# Создание группы безопасности

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = local.sg_nat_name
  network_id = yandex_vpc_network.netology.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
#    port           = 22
  }
}

# Cоздание образов дисков


resource "yandex_compute_disk" "boot-nat" {
  name     = "boot-nat"
  zone     = "ru-central1-b"
  image_id = "fd80mrhj8fl2oe87o4e1"
}


resource "yandex_compute_image" "ubuntu-1804-lts" {
  source_family = "ubuntu-1804-lts"
}

# Создание ВМ в публичной сети

resource "yandex_compute_instance" "public-vm" {
  name        = local.public-vm
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.ubuntu-1804-lts.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}

# Создание ВМ в приватной сети

resource "yandex_compute_instance" "private-vm" {
  name        = local.private-vm
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.ubuntu-1804-lts.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }

#  metadata = {
#    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
#  }
#}

  metadata = {
    user-data = "${file("metadata.yaml")}"
  }
}

# Создание ВМ NAT

resource "yandex_compute_instance" "nat-instance" {
  name        = local.vm_nat_name
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-nat.id
  }


  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
    ip_address         = "192.168.10.254"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}

# Создание таблицы маршрутизации

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = "${yandex_vpc_network.netology.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}
