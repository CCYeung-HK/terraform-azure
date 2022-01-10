# Outputs

output "tls_private_key" {
  value     = tls_private_key.key_ssh.private_key_pem
  sensitive = true
}

output "vm_identity_object_id" {
  value       = azurerm_linux_virtual_machine.vm.identity.0.principal_id
  description = "VM system-assigned identity id"
}

output "localip" {
  value = local.ifconfig_co_json.ip
}