locals {
  ssh_public_key = file(var.vm_common_params.ssh_public_key_path)
  
  # Формируем metadata с подстановкой SSH-ключа
  vm_metadata = {
    serial-port-enable = var.metadata["serial-port-enable"]
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
  }

  # Преобразование списка в map для использования с for_each
  each_vm_map = {
    for vm in var.each_vm : vm.vm_name => vm
  }

}