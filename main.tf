terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.77"
  
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "windler47-terraform-object-storage"
    region     = "ru-central1"
    key        = "terraform/windler47-personal-cloud.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yandex_oauth_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_availability_zone
}

resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  zone           = var.yandex_availability_zone
  network_id     = "${yandex_vpc_network.default.id}"
  name           = "default-ru-central1-a"
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_address" "wg-ru-1-public-adress" {
  name = "wg public ip adress"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_compute_instance" "wg-ru-1" {
  ## https://cloud.yandex.ru/docs/compute/concepts/vm-platforms
  platform_id = "standard-v2"  # Intel Cascade Lake
  resources {
    cores  = 2
    memory = 0.5
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = var.yandex_base_image_id
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-ru-central1-a.id}"
    nat = true
    nat_ip_address = "${yandex_vpc_address.wg-ru-1-public-adress.external_ipv4_address[0].address}"
  }

   metadata = {
    ssh-keys = "ubuntu:${file("id_ecdsa.pub")}"
  }

}