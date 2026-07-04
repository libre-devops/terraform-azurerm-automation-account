locals {
  rg = provider::azurerm::parse_resource_id(var.resource_group_id)
}

resource "azurerm_automation_account" "this" {
  resource_group_name = local.rg.resource_group_name
  location            = var.location
  tags                = var.tags

  name                          = var.name
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = var.local_authentication_enabled

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []

    content {
      key_vault_key_id          = encryption.value.key_vault_key_id
      key_source                = encryption.value.key_source
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }
}

resource "azurerm_automation_runtime_environment" "this" {
  for_each = var.runtime_environments

  automation_account_id    = azurerm_automation_account.this.id
  location                 = var.location
  tags                     = merge(var.tags, coalesce(each.value.tags, {}))
  name                     = each.key
  runtime_language         = each.value.runtime_language
  runtime_version          = each.value.runtime_version
  description              = each.value.description
  runtime_default_packages = each.value.runtime_default_packages
}

resource "azurerm_automation_runbook" "this" {
  for_each = var.runbooks

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  location                = var.location
  tags                    = merge(var.tags, coalesce(each.value.tags, {}))

  name                     = each.key
  runbook_type             = each.value.runbook_type
  content                  = each.value.content
  description              = each.value.description
  log_progress             = each.value.log_progress
  log_verbose              = each.value.log_verbose
  log_activity_trace_level = each.value.log_activity_trace_level
  runtime_environment_name = each.value.runtime_environment_name != null ? azurerm_automation_runtime_environment.this[each.value.runtime_environment_name].name : null

  dynamic "publish_content_link" {
    for_each = each.value.publish_content_link != null ? [each.value.publish_content_link] : []

    content {
      uri     = publish_content_link.value.uri
      version = publish_content_link.value.version

      dynamic "hash" {
        for_each = publish_content_link.value.hash != null ? [publish_content_link.value.hash] : []

        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
    }
  }
}

resource "azurerm_automation_schedule" "this" {
  for_each = var.schedules

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  frequency   = each.value.frequency
  interval    = each.value.interval
  start_time  = each.value.start_time
  expiry_time = each.value.expiry_time
  timezone    = each.value.timezone
  description = each.value.description
  week_days   = each.value.week_days
  month_days  = each.value.month_days

  dynamic "monthly_occurrence" {
    for_each = each.value.monthly_occurrence != null ? [each.value.monthly_occurrence] : []

    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
}

resource "azurerm_automation_job_schedule" "this" {
  for_each = var.job_schedules

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  runbook_name  = azurerm_automation_runbook.this[each.value.runbook_name].name
  schedule_name = azurerm_automation_schedule.this[each.value.schedule_name].name
  parameters    = each.value.parameters
  run_on        = each.value.run_on
}

resource "azurerm_automation_credential" "this" {
  # Key by the credential names (not secret); the values stay sensitive. for_each cannot iterate a
  # sensitive map directly, so the keys are lifted with nonsensitive and the values read by key.
  for_each = nonsensitive(toset(keys(var.credentials)))

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  username    = var.credentials[each.key].username
  password    = var.credentials[each.key].password
  description = var.credentials[each.key].description
}

resource "azurerm_automation_module" "this" {
  for_each = var.modules

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name = each.key

  module_link {
    uri = each.value.uri

    dynamic "hash" {
      for_each = each.value.hash != null ? [each.value.hash] : []

      content {
        algorithm = hash.value.algorithm
        value     = hash.value.value
      }
    }
  }
}

resource "azurerm_automation_powershell72_module" "this" {
  for_each = var.powershell72_modules

  automation_account_id = azurerm_automation_account.this.id
  tags                  = merge(var.tags, coalesce(each.value.tags, {}))
  name                  = each.key

  module_link {
    uri = each.value.uri

    dynamic "hash" {
      for_each = each.value.hash != null ? [each.value.hash] : []

      content {
        algorithm = hash.value.algorithm
        value     = hash.value.value
      }
    }
  }
}

resource "azurerm_automation_variable_string" "this" {
  for_each = { for k, v in var.variables : k => v if v.type == "string" }

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  value       = each.value.value
  description = each.value.description
  encrypted   = each.value.encrypted
}

resource "azurerm_automation_variable_int" "this" {
  for_each = { for k, v in var.variables : k => v if v.type == "int" }

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  value       = each.value.value != null ? tonumber(each.value.value) : null
  description = each.value.description
  encrypted   = each.value.encrypted
}

resource "azurerm_automation_variable_bool" "this" {
  for_each = { for k, v in var.variables : k => v if v.type == "bool" }

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  value       = each.value.value != null ? tobool(each.value.value) : null
  description = each.value.description
  encrypted   = each.value.encrypted
}

resource "azurerm_automation_variable_datetime" "this" {
  for_each = { for k, v in var.variables : k => v if v.type == "datetime" }

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  value       = each.value.value
  description = each.value.description
  encrypted   = each.value.encrypted
}

resource "azurerm_automation_variable_object" "this" {
  for_each = { for k, v in var.variables : k => v if v.type == "object" }

  resource_group_name     = local.rg.resource_group_name
  automation_account_name = azurerm_automation_account.this.name

  name        = each.key
  value       = each.value.value
  description = each.value.description
  encrypted   = each.value.encrypted
}
