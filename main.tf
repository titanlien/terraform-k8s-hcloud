terraform {
  backend "s3" {
    encrypt = true
    bucket = "tfstate-titan"
    key    = "hcloud-k8s/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "personal"
  public_key = file(var.ssh_public_key)
}

resource "hcloud_network" "privNet" {
  name     = "PrivNet"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "vlan1" {
  network_id = "${hcloud_network.privNet.id}"
  type = "server"
  network_zone = "eu-central"
  ip_range   = "10.0.1.0/24"
}

resource "hcloud_server_network" "srvnetwork" {
  count       = var.master_count
  server_id   = "${hcloud_server.master[count.index].id}"
  network_id  = "${hcloud_network.privNet.id}"
  ip = "10.0.1.${10+count.index}"
}

resource "hcloud_server_network" "slavnetwork" {
  count       = var.node_count
  server_id   = "${hcloud_server.node[count.index].id}"
  network_id  = "${hcloud_network.privNet.id}"
  ip = "10.0.1.${20+count.index}"
}

resource "hcloud_server" "master" {
  count       = var.master_count
  name        = "master-${count.index + 1}"
  server_type = var.master_type
  image       = var.master_image
  ssh_keys    = [hcloud_ssh_key.k8s_admin.name]
  location    = "fsn1"
}

resource "hcloud_server" "node" {
  count       = var.node_count
  name        = "node-${count.index + 1}"
  server_type = var.node_type
  image       = var.node_image
  depends_on  = [hcloud_server.master]
  ssh_keys    = [hcloud_ssh_key.k8s_admin.name]
  location    = "fsn1"
}

#resource "null_resource" "ansible-main" {
#  triggers = {
#    template_rendered = data.template_file.inventory.rendered
#  }
#  provisioner "local-exec" {
#    command = "ssh-keyscan -H ${hcloud_server.master.ipv4_address} >> ~/.ssh/known_hosts && ansible-playbook -e sshKey=${var.pvt_key} -i ./ansible/inventory --limit managers ./ansible/main.yml"
#  }
#
#  depends_on = ["hcloud_server.master", "null_resource.cmd"]
#}
