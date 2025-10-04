output "control_plane_ips" {
  value = { for k, v in local.all_nodes : k => v.ip if v.type == "control-plane" }
}

output "worker_ips" {
  value = { for k, v in local.all_nodes : k => v.ip if v.type == "worker" }
}
