variable "yandex_oauth_token" {
  description = "Yandex Oauth token"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex folder ID"
  type        = string
}

variable "yandex_availability_zone" {
  description = "Yandex Cloud availability zone"
  type        = string
}

variable "yandex_base_image_id" {
  description = "Yandex Cloud base image ID"
  type        = string
}