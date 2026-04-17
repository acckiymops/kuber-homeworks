###cloud vars
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}

# ###network var
variable "default_zone" {
  type    = string
  default = "ru-central1-d"
}
# variable "default_cidr" {
#   type        = list(string)
#   default     = ["10.130.0.0/24"]
# }
# variable "vpc_name" {
#   type        = string
#   default     = "default"
# }

###ssh vars
variable "ssh_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF50M64NjbGvXTiqoWIxxmT6VTaDUnu4U+0qHaTfL59z mvmeles1@ubuntu"
}

#compute vars
variable "project" {
  default = "netology"
}
variable "vm_image_id" {
  type    = string
  default = "ubuntu-2004-lts"
}
