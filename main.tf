terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.77"
}

provider "yandex" {
  token     = yandex.token
  cloud_id  = yandex.cloud_id
  folder_id = yandex.folder_id
  zone      = yandex.zone
}