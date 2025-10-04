locals {
  all_nodes = concat(
    [for i in range(var.control_plane_nodes) : {
      name = "control-plane-${i}"
      ip   = cidrhost(var.cluster_cidr, i + 200)
      type = "control-plane"
    }],
    [for i in range(var.worker_nodes) : {
      name = "worker-${i}"
      ip   = cidrhost(var.cluster_cidr, i + 210)
      type = "worker"
    }]
  )
}
