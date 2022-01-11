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



