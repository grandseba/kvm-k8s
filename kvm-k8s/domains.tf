resource "libvirt_domain" "control_plane" {
  for_each = { for node in local.all_nodes : node.name => node if node.type == "control-plane" }

  name   = each.key
  memory = 4096
  vcpu   = 2

  network_interface {
    bridge  = var.bridge_name
  }

  disk {
    volume_id = libvirt_volume.control_plane_image[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.k8s_cloudinit[each.key].id

  console {
    type = "pty"
    target_type = "serial"
  }

  graphics {
    type = "spice"
  }

  connection {
    type        = "ssh"
    host        = each.value.ip
    user        = "seb"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "install_k8s.sh"
    destination = "/tmp/install_k8s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_k8s.sh",
      "export K8S_RELEASE=${var.k8s_release}",
      "export K8S_ARCH=${var.k8s_arch}",
      "export K8S_RELEASE_VERSION=${var.k8s_release_version}",
      "sudo /tmp/install_k8s.sh"
    ]
  }
}

resource "libvirt_domain" "worker" {
  for_each = { for node in local.all_nodes : node.name => node if node.type == "worker" }

  name   = each.key
  memory = 4096
  vcpu   = 2

  network_interface {
    bridge  = var.bridge_name
  }

  disk {
    volume_id = libvirt_volume.worker_image[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.k8s_cloudinit[each.key].id

  connection {
    type        = "ssh"
    host        = each.value.ip
    user        = "seb"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "install_k8s.sh"
    destination = "/tmp/install_k8s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_k8s.sh",
      "export K8S_RELEASE=${var.k8s_release}",
      "export K8S_ARCH=${var.k8s_arch}",
      "export K8S_RELEASE_VERSION=${var.k8s_release_version}",
      "sudo /tmp/install_k8s.sh"
    ]
  }
}
