output "automation_account" {
  description = "The full automation account object. Sensitive as a whole because it carries the DSC/registration keys; the id, name, and identity outputs alongside stay plain for composition."
  value       = azurerm_automation_account.this
  sensitive   = true
}

output "automation_account_id" {
  description = "The automation account id."
  value       = azurerm_automation_account.this.id
}

output "automation_account_name" {
  description = "The automation account name."
  value       = azurerm_automation_account.this.name
}

output "identity_principal_ids" {
  description = "The account's { system_assigned } identity principal id (null where absent)."
  value = {
    system_assigned = try(azurerm_automation_account.this.identity[0].principal_id, null)
  }
}

output "runbook_ids" {
  description = "Map of runbook name to id."
  value       = { for k, r in azurerm_automation_runbook.this : k => r.id }
}

output "runtime_environment_ids" {
  description = "Map of runtime environment name to id."
  value       = { for k, e in azurerm_automation_runtime_environment.this : k => e.id }
}

output "schedule_ids" {
  description = "Map of schedule name to id."
  value       = { for k, s in azurerm_automation_schedule.this : k => s.id }
}
