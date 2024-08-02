locals {
  target_folder_id = "b1g8glslhvn0od004lvq"
  zone = "ru-central1-d"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  backend "s3" {
    endpoints = {
      s3        = "https://storage.yandexcloud.net"
      dynamodb  = "https://docapi.serverless.yandexcloud.net/ru-central1/b1ghcdiesvi7hvcfvag5/etnp2pgupsoj2419q6or"
    }
    bucket = "windler47-tf"
    region = "ru-central1"
    key    = "windler47.tfstate"
    
    dynamodb_table = "state-lock-table"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  } 
}

provider "yandex" {
  zone = local.zone
  service_account_key_file = "key.json"
  folder_id  = local.target_folder_id
}

data "yandex_compute_image" "ubuntu-2404-lts-oslogin" {
  family = "ubuntu-2404-lts-oslogin"
}

# data "yandex_vpc_network" "network_default" {
#   name = "default"
# }

data "yandex_vpc_subnet" "default-ru-central1-d" {
  name = "default-ru-central1-d"
}

resource "yandex_compute_disk" "wireguard-out-disk" {
  name     = "wireguard-out-disk"
  type     = "network-hdd"
  size     = "10"
  image_id = data.yandex_compute_image.ubuntu-2404-lts-oslogin.id
}

resource "yandex_compute_instance" "wireguard-out" {
  # https://yandex.cloud/ru/docs/compute/concepts/performance-levels
  platform_id = "standard-v2"
  resources {
    core_fraction = "20"
    cores  = "2"
    memory = "1"
  }
  
  boot_disk {
    disk_id = yandex_compute_disk.wireguard-out-disk.id
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default-ru-central1-d.id
    nat       = true
  }
  
  name                      = "wireguard-out"
  hostname                  = "wireguard-out"

  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }
}
