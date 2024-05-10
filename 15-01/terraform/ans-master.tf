## Ansible inventory for master-vm
resource "local_file" "ansible-inventory-master-vm" {
  content = <<-DOC
    kuber:
      hosts:
        ${yandex_compute_instance.sample["master-vm"].fqdn}:
          ansible_host: ${yandex_compute_instance.sample["master-vm"].network_interface.0.nat_ip_address}
    DOC
  filename = "../ansible/ansible-inventory-master-vm"
  depends_on = [yandex_compute_instance.sample["master-vm"]]
}

