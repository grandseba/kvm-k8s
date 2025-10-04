variable "base_image_url" {
  description = "URL de l’image cloud Debian ou Ubuntu"
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "pool_path" {
  default = "/var/lib/libvirt/images"
}

variable "bridge_name" {
  description = "Nom du pont réseau libvirt (ex: br0)"
  default     = "br0"
}

variable "cluster_cidr" {
  description = "CIDR du réseau du cluster"
  default     = "192.168.1.0/24"
}

variable "control_plane_nodes" {
  default = 1
}

variable "worker_nodes" {
  default = 0
}

variable "ssh_private_key_path" {
  description = "Chemin vers ta clé SSH privée"
  default     = "~/.ssh/id_rsa.pub"
}

variable "k8s_release" {
  default = "v1.34.1"
}

variable "k8s_arch" {
  default = "amd64"
}

variable "k8s_release_version" {
  default = "release-1.34"
}
