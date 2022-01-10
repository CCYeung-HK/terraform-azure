# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

data "http" "localpublicip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.localpublicip.body)
}

# Resources

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ap-cloud-quiz-rg"
  location = var.location
  tags = {
    environment  = var.environment
    source       = "Terrform"
    resourceType = "general-rg"
    tagVersion   = var.tagversion
  }
}

# Create Network related resources

resource "azurerm_network_security_group" "nsg" {
  name                = "ap-cloud-quiz-nsg1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ap-cloud-quiz-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "ap-cloud-quiz-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "ap-cloud-quiz-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  # tags = {}
}

resource "azurerm_network_interface" "nic" {
  name                = "ap-cloud-quiz-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create SSH Key

# resource "tls_private_key" "key_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# Create storage account for boot diagnostic

# resource "azurerm_storage_account" "storageaccount" {
#     name = "ap-cloud-quiz-storageaccount"
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     account_tier = "Standard"
#     account_replication_type = "LRS"

#     # tags = {}
# }

# Create Linux VM 

# resource "azurerm_linux_virtual_machine" "vm" {
#   name                = "ap-cloud-quiz-vm"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_DS1"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = tls_private_key.key_ssh.public_key_openssh
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   # boot_diagnostics {
#   #   storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
#   # }

#   # tags = {}
# }

# Create SQL Server, SQL Database

# resource "azurerm_sql_server" "sqlserver" {
#   name                         = "ap-cloud-quiz-sqlserver"
#   resource_group_name          = azurerm_resource_group.rg.name
#   location                     = azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = "quizadministrator"
#   administrator_login_password = var.sqlserver-admin-password
# } 

# resource "azurerm_sql_database" "sqldatabase" {
#   name                = "ap-cloud-quiz-sqldatabase"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   server_name         = azurerm_sql_server.sqlserver.name
# }

# Create Key Vault

# resource "azurerm_key_vault" "keyvault" {
#   name = "quiz-keyvault"
#   location = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   enabled_for_disk_encryption = true
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days = 7
#   purge_protection_enabled = false

#   sku_name = "standard"
# }

# resource "azurerm_key_vault_secret" "secret-sqlpassword" {
#   name = "ap-cloud-quiz-sqldatabase-password"
#   value = var.sqlserver-admin-password
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

# Configurations

# Network Security Group rules

resource "azurerm_network_security_rule" "nsg-rule-inbound-1" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "nsg-rule-inbound-2" {
  name                        = "HTTPS"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# resource "azurerm_sql_firewall_rule" "sqlserver-firewallrule" {
#   name = "ap-cloud-quiz-sqlserver-firewallrule-1"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name = azurerm_sql_server.sqlserver.name
#   start_ip_address = azurerm_linux_virtual_machine.vm.public_ip_address
#   end_ip_address = azurerm_linux_virtual_machine.vm.public_ip_address
# }

# resource "azurerm_sql_firewall_rule" "local" {
#   name = "local"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name = azurerm_sql_server.sqlserver.name
#   start_ip_address = "123.203.190.186"
#   end_ip_address = "123.203.190.186"
# }

# resource "azurerm_key_vault_access_policy" "keyvault-accesspolicy-user" {
#   key_vault_id = azurerm_key_vault.keyvault.id
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
#   ]

#   secret_permissions = [
#     "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
#   ]

#   depends_on = [
#     azurerm_key_vault.keyvault,
#   ]

# }

# resource "azurerm_key_vault_access_policy" "keyvault-accesspolicy-vm" {
#   key_vault_id = azurerm_key_vault.keyvault.id
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = azurerm_linux_virtual_machine.vm.identity.0.principal_id

#   secret_permissions = [
#     "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
#   ]

# }



