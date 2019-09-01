variable "hcloud_token" {}

variable "master_count" {
  default = 1
}

variable "master_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-16.04, debian-9,centos-7,fedora-27)"
  default     = "7351878"
}

variable "master_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "node_count" {
  default = 1
}

variable "node_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-16.04, debian-9,centos-7,fedora-27)"
  default     = "7351878"
}

variable "node_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "ssh_private_key" {
  description = "Private Key to access the machines"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_rsa.pub"
}

variable "calico_enabled" {
  default     = true
}
