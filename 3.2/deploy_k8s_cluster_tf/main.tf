data "yandex_vpc_network" "default" {
  network_id = "enp31rvs2ffuhcfg2lgp"
}
data "yandex_vpc_subnet" "default" {
  subnet_id = "fl8kdjhrtt7cfua85pbl"
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_id
}

resource "yandex_compute_instance" "master-node" {
  name        = "kube-master"
  hostname    = "kube-master"
  platform_id = "standard-v3"
  zone        = var.default_zone
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = false
  }
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s-all.id]
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.ssh_key}"
    user-data  = local.k8s_setup_script
  }
}

resource "yandex_compute_instance" "worker-node" {
  count       = 4
  name        = "kube-worker-${count.index + 1}"
  hostname    = "kube-worker-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.default_zone
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = false
  }
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s-all.id]
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.ssh_key}"
    user-data  = local.k8s_setup_script
  }
}

resource "yandex_vpc_security_group" "k8s-all" {
  name        = "k8s-all-sg"
  description = "Security group for all Kubernetes nodes"
  network_id  = data.yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API Server"
    port           = 6443
    v4_cidr_blocks = ["10.130.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "etcd"
    from_port      = 2379
    to_port        = 2380
    v4_cidr_blocks = [data.yandex_vpc_subnet.default.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubelet API"
    port           = 10250
    v4_cidr_blocks = [data.yandex_vpc_subnet.default.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    description    = "kube-scheduler"
    port           = 10259
    v4_cidr_blocks = [data.yandex_vpc_subnet.default.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    description    = "kube-controller-manager"
    port           = 10257
    v4_cidr_blocks = [data.yandex_vpc_subnet.default.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    description    = "kube-proxy"
    port           = 10256
    v4_cidr_blocks = [data.yandex_vpc_subnet.default.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    description    = "NodePort Services"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["10.130.0.0/24"]
  }

  ingress {
    protocol       = "UDP"
    description    = "NodePort Services UDP"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["10.130.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["10.130.0.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
