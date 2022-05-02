resource "azurerm_automation_account" "aa" {
  name                          = var.automation_account_name
  location                      = var.location
  resource_group_name           = var.rg_name
  tags                          = var.tags
  sku_name                      = title(var.sku_name)
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
}