# vpc
resource "yandex_vpc_network" "net-diplom" {
  name = "net-diplom"
  folder_id = var.yc_folder_id
}

# subnets
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net-diplom.id
  v4_cidr_blocks = ["192.168.100.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net-diplom.id
  v4_cidr_blocks = ["192.168.150.0/24"]
}

resource "yandex_vpc_subnet" "subnet-d" {
  name           = "subnet-d"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net-diplom.id
  v4_cidr_blocks = ["192.168.200.0/24"]
}
