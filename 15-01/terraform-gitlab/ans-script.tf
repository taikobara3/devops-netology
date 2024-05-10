## Script for installation of Kubernetes with Kubespray
resource "local_file" "deploy-k8s" {
  content = <<-DOC
    #!/bin/bash
    set -euxo pipefail
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-master-vm prepare-master.yml
    sleep 20
    ssh ubuntu@${yandex_compute_instance.sample["master-vm"].network_interface.0.nat_ip_address} 'export ANSIBLE_HOST_KEY_CHECKING=False; export ANSIBLE_ROLES_PATH=/home/ubuntu/kubespray/roles:/home/ubuntu/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles; ansible-playbook -i /home/ubuntu/kubespray/inventory/mycluster/hosts.yaml -u ubuntu -b -v --private-key=/home/ubuntu/.ssh/id_rsa /home/ubuntu/kubespray/cluster.yml'
    sleep 20
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-master-vm get-kubeconfig.yml
    sleep 5
    sed -i -e 's,server: https://127.0.0.1:6443,server: https://${yandex_compute_instance.sample["master-vm"].network_interface.0.nat_ip_address}:6443,g'  ~/.kube/config
    DOC
  filename = "../ansible/deploy-k8s.sh"
  depends_on = [yandex_compute_instance.sample["master-vm"], yandex_compute_instance.sample["worker-vm-1"], yandex_compute_instance.sample["worker-vm-2"], yandex_compute_instance.sample["worker-vm-3"]]
}

## Set execution bit on install script
resource "null_resource" "chmod" {
  provisioner "local-exec" {
    command = "chmod 755 ../ansible/deploy-k8s.sh"
  }
  depends_on = [local_file.deploy-k8s]
}
