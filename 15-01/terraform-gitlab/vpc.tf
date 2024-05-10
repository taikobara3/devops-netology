# vpc
resource "yandex_vpc_network" "net-diplom" {
  name = "net-diplom"
  folder_id = var.yc_folder_id
}

# subnets

resource "yandex_vpc_subnet" "sample" {
for_each =  { for nw in local.vmnw_k8s: "${nw.name}" => nw }

  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.net-diplom.id
  v4_cidr_blocks = each.value.cidr
}

locals {
  vmnw_k8s = [
        {
        name    = "subnet-a"
        zone    = "ru-central1-a"
        cidr    = ["192.168.100.0/24"]
        },
        {
        name    = "subnet-b"
        zone    = "ru-central1-b"
        cidr    = ["192.168.150.0/24"]
        },
        {
        name    = "subnet-d"
        zone    = "ru-central1-b"
        cidr    = ["192.168.200.0/24"]
        }
  ]
}

