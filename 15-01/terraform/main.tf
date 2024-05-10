# Terraform providers
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
    endpoints = "https://storage.yandexcloud.net"
  }

}

provider "yandex" {
  token     = var.yc_token_id
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_region
}
