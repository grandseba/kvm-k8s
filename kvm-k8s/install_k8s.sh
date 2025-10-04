#!/bin/bash
set -eux

K8S_BIN_DIR="/usr/local/bin"

# Prérequis
apt-get update
apt-get install -y apt-transport-https ca-certificates curl containerd qemu-guest-agent

systemctl enable --now qemu-guest-agent

# Activer modules et sysctl
echo -e "overlay\nbr_netfilter" > /etc/modules-load.d/k8s.conf
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

swapoff -a
sed -i '/swap/ s/^/#/' /etc/fstab

# Installer kubeadm / kubelet / kubectl
curl -L --remote-name-all https://dl.k8s.io/release/${K8S_RELEASE}/bin/linux/${K8S_ARCH}/{kubeadm,kubelet,kubectl}
chmod +x kubeadm kubelet kubectl
mv kubeadm kubelet kubectl ${K8S_BIN_DIR}/

curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" \
  | sed "s:/usr/bin:${K8S_BIN_DIR}:g" | tee /usr/lib/systemd/system/kubelet.service

mkdir -p /usr/lib/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" \
  | sed "s:/usr/bin:${K8S_BIN_DIR}:g" | tee /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl enable kubelet

# Init du cluster (master)
if [[ $(hostname) == control-plane-0 ]]; then
  kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --skip-phases=addon/kube-proxy
  mkdir -p /home/seb/.kube
  cp -i /etc/kubernetes/admin.conf /home/seb/.kube/config
  chown seb:seb /home/seb/.kube/config

  curl -L https://raw.githubusercontent.com/cilium/cilium/v1.14.3/install/kubernetes/quick-install.yaml | kubectl apply -f -
fi
