resource "yandex_iam_service_account" "sa-diplom" {
    folder_id = var.yc_folder_id
    name      = "sa-diplom"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
    folder_id = var.yc_folder_id
    role      = "editor"
    member    = "serviceAccount:${yandex_iam_service_account.sa-diplom.id}"
    depends_on = [yandex_iam_service_account.sa-diplom]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
    service_account_id = yandex_iam_service_account.sa-diplom.id
    description        = "static access key"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "sa-backet" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "sa-backet"
    acl    = "private"
    force_destroy = true
}

// Create "local_file" for "backendConf"
resource "local_file" "backendConf" {
  content  = <<EOT
endpoint = "storage.yandexcloud.net"
bucket = "${yandex_storage_bucket.sa-backet.bucket}"
region = "ru-central1"
key = "terraform/terraform.tfstate"
access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
skip_region_validation = true
skip_credentials_validation = true
EOT
  filename = "../backend.key"
}

// Add "backendConf" to bucket
resource "yandex_storage_object" "object" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.sa-backet.bucket
    key = "terraform.tfstate"
    source = "./terraform.tfstate"
    acl    = "private"
    depends_on = [yandex_storage_bucket.sa-backet]
}
