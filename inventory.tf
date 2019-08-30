data "template_file" "inventory" {
  template = file("templates/inventory.tpl")

  depends_on = [
    hcloud_server.master,
    hcloud_server.node,
  ]

  vars = {
    managers = join(
      "\n",
      hcloud_server.master.*.ipv4_address,
    )
    nodes = join(
      "\n",
      hcloud_server.node.*.ipv4_address,
    )
  }
}

resource "null_resource" "cmd" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ./ansible/inventory"
  }
}

