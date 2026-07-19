output "vms_info" {
  description = "Information about all VM instances"

  sensitive = false

  value = {
    for vm in local.all_vms :
    vm.name => {
      instance_name = vm.name
      external_ip   = vm.network_interface[0].nat_ip_address
      fqdn          = vm.fqdn
    }
  }
}