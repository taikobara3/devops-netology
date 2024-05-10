## Ansible inventory for Kubespray configuration
resource "null_resource" "ansible-kubespray-k8s-config" {
  provisioner "local-exec" {
    command = "wget --quiet https://raw.githubusercontent.com/kubernetes-sigs/kubespray/master/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml -O ../ansible/k8s-cluster.yml"
  }
  depends_on = [yandex_compute_instance.sample["master-vm"], yandex_compute_instance.sample["worker-vm-1"], yandex_compute_instance.sample["worker-vm-2"], yandex_compute_instance.sample["worker-vm-3"]]
}
resource "null_resource" "ansible-kubespray-k8s-config-add" {
  provisioner "local-exec" {
    command = "echo 'supplementary_addresses_in_ssl_keys: [ ${yandex_compute_instance.sample["master-vm"].network_interface.0.nat_ip_address} ]' >> ../ansible/k8s-cluster.yml"
  }
  depends_on = [null_resource.ansible-kubespray-k8s-config]
}
