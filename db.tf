resource "azurerm_sql_server" "sqlserver" {
  name                         = "ap-cloud-quiz-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "quizadministrator"
  administrator_login_password = var.sqlserver-admin-password
}

resource "azurerm_sql_database" "sqldatabase" {
  name                = "ap-cloud-quiz-sqldatabase"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlserver.name
}

resource "azurerm_sql_firewall_rule" "sqlserver-firewallrule" {
  name                = "ap-cloud-quiz-sqlserver-firewallrule-1"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sqlserver.name
  start_ip_address    = azurerm_linux_virtual_machine.vm.public_ip_address
  end_ip_address      = azurerm_linux_virtual_machine.vm.public_ip_address
}

resource "azurerm_sql_firewall_rule" "local" {
  name                = "local"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sqlserver.name
  start_ip_address    = local.ifconfig_co_json.ip
  end_ip_address      = local.ifconfig_co_json.ip
}