data "template_file" "user_data" {
  for_each = { for node in local.all_nodes : node.name => node }

  template = file("${path.module}/cloud_init.yml")

  vars = {
    hostname            = each.value.name
  }
}

resource "libvirt_cloudinit_disk" "k8s_cloudinit" {
  for_each = data.template_file.user_data

  name      = "${each.key}-cloudinit.iso"
  user_data = each.value.rendered
  pool      = var.pool_path
}
