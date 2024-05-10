# Kubespray preparation
## Ansible inventory for Kuberspray
resource "local_file" "ansible-inventory-kubespray" {
  content = <<EOF
all:
  hosts:
    ${yandex_compute_instance.sample["master-vm"].fqdn}:
      ansible_host: ${yandex_compute_instance.sample["master-vm"].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.sample["master-vm"].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.sample["master-vm"].network_interface.0.ip_address}
    ${yandex_compute_instance.sample["worker-vm-1"].fqdn}:
      ansible_host: ${yandex_compute_instance.sample["worker-vm-1"].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.sample["worker-vm-1"].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.sample["worker-vm-1"].network_interface.0.ip_address}
    ${yandex_compute_instance.sample["worker-vm-2"].fqdn}:
      ansible_host: ${yandex_compute_instance.sample["worker-vm-2"].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.sample["worker-vm-2"].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.sample["worker-vm-2"].network_interface.0.ip_address}
    ${yandex_compute_instance.sample["worker-vm-3"].fqdn}:
      ansible_host: ${yandex_compute_instance.sample["worker-vm-3"].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.sample["worker-vm-3"].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.sample["worker-vm-3"].network_interface.0.ip_address}
  children:
    kube_control_plane:
      hosts:
        ${yandex_compute_instance.sample["master-vm"].fqdn}:
    kube_node:
      hosts:
        ${yandex_compute_instance.sample["worker-vm-1"].fqdn}:
        ${yandex_compute_instance.sample["worker-vm-2"].fqdn}:
        ${yandex_compute_instance.sample["worker-vm-3"].fqdn}:
    etcd:
      hosts:
        ${yandex_compute_instance.sample["master-vm"].fqdn}:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
  EOF
  filename = "../ansible/ansible-inventory-kubespray"
  depends_on = [yandex_compute_instance.sample["master-vm"], yandex_compute_instance.sample["worker-vm-1"], yandex_compute_instance.sample["worker-vm-2"], yandex_compute_instance.sample["worker-vm-3"]]
}

