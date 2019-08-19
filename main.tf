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

resource "hcloud_server" "master" {
  count       = var.master_count
  name        = "master-${count.index + 1}"
  server_type = var.master_type
  image       = var.master_image
  ssh_keys    = [hcloud_ssh_key.k8s_admin.name]
  location    = "fsn1"

  provisioner "file" {
    source      = "files/10-kubeadm.conf"
    destination = "/root/10-kubeadm.conf"
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "scripts/master.sh"
    destination = "/root/master.sh"
  }

  provisioner "remote-exec" {
    inline = ["CORE_DNS=${var.core_dns} bash /root/master.sh"]
  }

  provisioner "local-exec" {
    command = "bash scripts/copy-kubeadm-token.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME    = "root"
      SSH_HOST        = "${hcloud_server.master[count.index].ipv4_address}"
      TARGET          = "${path.module}/secrets/"
    }
  }
}

resource "hcloud_server" "node" {
  count       = "${var.node_count}"
  name        = "node-${count.index + 1}"
  server_type = "${var.node_type}"
  image       = "${var.node_image}"
  depends_on  = ["hcloud_server.master"]
  ssh_keys    = ["hcloud_ssh_key.k8s_admin.name"]
  location    = "fsn1"

  provisioner "file" {
    source      = "files/10-kubeadm.conf"
    destination = "/root/10-kubeadm.conf"
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"
  }

  provisioner "file" {
    source      = "scripts/node.sh"
    destination = "/root/node.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/node.sh"]
  }
}
