# Terraform providers
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
#  required_version = ">= 0.13"
  backend "s3" {
#    endpoint                    = "storage.yandexcloud.net"
#    bucket                      = "sa-backet"
#    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
#    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#    region                      = "ru-central1-a"
#    key                         = "tfstate"
#    skip_region_validation      = true
#    skip_credentials_validation = true    

    endpoints = "https://storage.yandexcloud.net"
    
#    bucket = "sa-backet"
#    region = "ru-central1"
#    key    = "terraform.tfstate"
#    access_key = ajetq66e7ao766k1cab2
#    secret_key = YCAJEE_X5RHQb4x-Fbj5f5f9U

#    skip_region_validation      = true
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
#    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }

}

provider "yandex" {
#  service_account_key_file = "key.json"
  token     = var.yc_token_id
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_region
}

# Kubespray preparation
## Ansible inventory for Kuberspray
resource "local_file" "ansible-inventory-kubespray" {
  content = <<EOF
all:
  hosts:
    ${yandex_compute_instance.master-vm.fqdn}:
      ansible_host: ${yandex_compute_instance.master-vm.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.master-vm.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.master-vm.network_interface.0.ip_address}
    ${yandex_compute_instance.worker-vm-1.fqdn}:
      ansible_host: ${yandex_compute_instance.worker-vm-1.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.worker-vm-1.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.worker-vm-1.network_interface.0.ip_address}
    ${yandex_compute_instance.worker-vm-2.fqdn}:
      ansible_host: ${yandex_compute_instance.worker-vm-2.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.worker-vm-2.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.worker-vm-2.network_interface.0.ip_address}
    ${yandex_compute_instance.worker-vm-3.fqdn}:
      ansible_host: ${yandex_compute_instance.worker-vm-3.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.worker-vm-3.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.worker-vm-3.network_interface.0.ip_address}
  children:
    kube_control_plane:
      hosts:
        ${yandex_compute_instance.master-vm.fqdn}:
    kube_node:
      hosts:
        ${yandex_compute_instance.worker-vm-1.fqdn}:
        ${yandex_compute_instance.worker-vm-2.fqdn}:
        ${yandex_compute_instance.worker-vm-3.fqdn}:
    etcd:
      hosts:
        ${yandex_compute_instance.master-vm.fqdn}:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
  EOF
  filename = "../ansible/ansible-inventory-kubespray"
  depends_on = [yandex_compute_instance.master-vm, yandex_compute_instance.worker-vm-1, yandex_compute_instance.worker-vm-2, yandex_compute_instance.worker-vm-3]
}

## Ansible inventory for master-vm
resource "local_file" "ansible-inventory-master-vm" {
  content = <<-DOC
    kuber:
      hosts:
        ${yandex_compute_instance.master-vm.fqdn}:
          ansible_host: ${yandex_compute_instance.master-vm.network_interface.0.nat_ip_address}
    DOC
  filename = "../ansible/ansible-inventory-master-vm"
  depends_on = [yandex_compute_instance.master-vm, yandex_compute_instance.worker-vm-1, yandex_compute_instance.worker-vm-2, yandex_compute_instance.worker-vm-3]
}

## Ansible inventory for Kubespray configuration
resource "null_resource" "ansible-kubespray-k8s-config" {
  provisioner "local-exec" {
    command = "wget --quiet https://raw.githubusercontent.com/kubernetes-sigs/kubespray/master/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml -O ../ansible/k8s-cluster.yml"
  }
  depends_on = [yandex_compute_instance.master-vm, yandex_compute_instance.worker-vm-1, yandex_compute_instance.worker-vm-2, yandex_compute_instance.worker-vm-3]
}
resource "null_resource" "ansible-kubespray-k8s-config-add" {
  provisioner "local-exec" {
    command = "echo 'supplementary_addresses_in_ssl_keys: [ ${yandex_compute_instance.master-vm.network_interface.0.nat_ip_address} ]' >> ../ansible/k8s-cluster.yml"
  }
  depends_on = [null_resource.ansible-kubespray-k8s-config]
}

## Script for installation of Kubernetes with Kubespray
resource "local_file" "deploy-k8s" {
  content = <<-DOC
    #!/bin/bash
    set -euxo pipefail
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-master-vm prepare-master.yml
    sleep 20
    ssh ubuntu@${yandex_compute_instance.master-vm.network_interface.0.nat_ip_address} 'export ANSIBLE_HOST_KEY_CHECKING=False; export ANSIBLE_ROLES_PATH=/home/ubuntu/kubespray/roles:/home/ubuntu/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles; ansible-playbook -i /home/ubuntu/kubespray/inventory/mycluster/hosts.yaml -u ubuntu -b -v --private-key=/home/ubuntu/.ssh/id_rsa /home/ubuntu/kubespray/cluster.yml'
    sleep 20
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-master-vm get-kubeconfig.yml
    sleep 5
    sed -i -e 's,server: https://127.0.0.1:6443,server: https://${yandex_compute_instance.master-vm.network_interface.0.nat_ip_address}:6443,g'  ~/.kube/config
    DOC
  filename = "../ansible/deploy-k8s.sh"
  depends_on = [yandex_compute_instance.master-vm, yandex_compute_instance.worker-vm-1, yandex_compute_instance.worker-vm-2, yandex_compute_instance.worker-vm-3]
}

## Set execution bit on install script
resource "null_resource" "chmod" {
  provisioner "local-exec" {
    command = "chmod 755 ../ansible/deploy-k8s.sh"
  }
  depends_on = [local_file.deploy-k8s]
}
