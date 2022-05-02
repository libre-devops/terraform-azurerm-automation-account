output "aa_dsc_primary_access_key" {
  value       = azurerm_automation_account.aa.dsc_primary_access_key
  description = "The DSC primary access key"
  sensitive   = true
}

output "aa_dsc_secondary_access_key" {
  value       = azurerm_automation_account.aa.dsc_secondary_access_key
  description = "The DSC secondary access key"
  sensitive   = true
}

output "aa_dsc_server_endpoint" {
  value       = azurerm_automation_account.aa.dsc_server_endpoint
  description = "The DSC server endpoint of the automation account"
}

output "aa_id" {
  value       = azurerm_automation_account.aa.id
  description = "The ID of the automation account"
}

output "aa_identity" {
  value       = azurerm_automation_account.aa.*.identity
  description = "The identity block of the automation account"
}

output "aa_name" {
  value       = azurerm_automation_account.aa.name
  description = "The name of the automation account"
}
