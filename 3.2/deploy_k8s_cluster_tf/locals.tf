# Создаем общий шаблон
locals {
  k8s_setup_script = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl gpg
    sudo apt install -y containerd
    
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
    sudo apt update -y
    sudo apt install -y kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    # Включаем IP forwarding
    sudo sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
    
    # Отключаем swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    
    # Загружаем модули
    sudo modprobe overlay
    sudo modprobe br_netfilter
    
    # Настройки Kubernetes
    cat <<EOT | sudo tee /etc/sysctl.d/99-kubernetes.conf
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward = 1
    EOT
    sudo sysctl --system
  EOF
}