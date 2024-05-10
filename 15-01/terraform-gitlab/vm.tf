# VM
resource "yandex_compute_instance" "sample" {
  for_each =  { for vm in local.vms_k8s: "${vm.name}" => vm }

  name = each.key
  hostname = each.value.hostname
  zone      = each.value.zone
  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }
  boot_disk {
    initialize_params {
      image_id = "fd83s8u085j3mq231ago"
      size = "20"
    }
  }
  network_interface {
    subnet_id = each.value.subnet_id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

locals {
  vms_k8s = [
        {
        name = "master-vm"
        hostname = "master-vm"
        zone    = "ru-central1-a"
        cores   = 4
        memory  = 8
        subnet_id = yandex_vpc_subnet.sample["subnet-a"].id
        },
        {
        name = "worker-vm-1"
        hostname = "worker-vm-1"
        zone    = "ru-central1-a"
        cores   = 2
        memory  = 4
        subnet_id = yandex_vpc_subnet.sample["subnet-a"].id
        },
        {
        name = "worker-vm-2"
        hostname = "worker-vm-2"
        zone    = "ru-central1-b"
        cores   = 2
        memory  = 4
        subnet_id = yandex_vpc_subnet.sample["subnet-b"].id
        },
        {
        name = "worker-vm-3"
        hostname = "worker-vm-3"
        zone    = "ru-central1-b"
        cores   = 2
        memory  = 4
        subnet_id = yandex_vpc_subnet.sample["subnet-d"].id
        }
  ]
}
