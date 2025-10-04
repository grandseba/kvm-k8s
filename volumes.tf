resource "libvirt_volume" "base_image" {
  name   = "debian-13-base.qcow2"
  pool   = var.pool_path
  source = var.base_image_url
  format = "qcow2"
}

resource "libvirt_volume" "control_plane_image" {
  for_each = { for node in local.all_nodes : node.name => node if node.type == "control-plane" }

  name   = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.base_image.id
  pool   = var.pool_path
}

resource "libvirt_volume" "worker_image" {
  for_each = { for node in local.all_nodes : node.name => node if node.type == "worker" }

  name   = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.base_image.id
  pool   = var.pool_path
}
