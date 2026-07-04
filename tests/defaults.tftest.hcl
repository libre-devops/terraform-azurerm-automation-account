# Tests for the module. azurerm is mocked (no credentials, no cloud):
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {
  mock_resource "azurerm_automation_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001/providers/Microsoft.Automation/automationAccounts/aa-mock"
    }
  }
}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  name              = "aa-ldo-uks-tst-001"
  tags              = { Environment = "tst" }
}

# Nothing but a name: a Basic account with a system-assigned identity.
run "fast_to_get_going" {
  command = apply

  assert {
    condition     = azurerm_automation_account.this.sku_name == "Basic"
    error_message = "sku_name should default to Basic."
  }

  assert {
    condition     = azurerm_automation_account.this.identity[0].type == "SystemAssigned"
    error_message = "The identity should default to SystemAssigned."
  }
}

# Runbooks, a runtime environment, schedules, a job schedule linking them, variables, and a module.
run "full_surface" {
  command = apply

  variables {
    runtime_environments = {
      "pwsh-74" = { runtime_language = "PowerShell", runtime_version = "7.4" }
    }

    runbooks = {
      "sync-groups" = {
        runbook_type             = "PowerShell72"
        content                  = "Write-Output 'hello'"
        runtime_environment_name = "pwsh-74"
      }
      "from-uri" = {
        runbook_type         = "PowerShell"
        publish_content_link = { uri = "https://example.com/runbook.ps1" }
      }
    }

    schedules = {
      "daily" = { frequency = "Day", interval = 1, timezone = "Etc/UTC" }
    }

    job_schedules = {
      "sync-daily" = { runbook_name = "sync-groups", schedule_name = "daily" }
    }

    variables = {
      " tenant_id " = { type = "string", value = "contoso" }
      "retries"     = { type = "int", value = "3" }
      "enabled"     = { type = "bool", value = "true" }
    }

    modules = {
      "Az.Accounts" = { uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts" }
    }
  }

  assert {
    condition     = length(azurerm_automation_runbook.this) == 2
    error_message = "Both runbooks should be created."
  }

  assert {
    condition     = azurerm_automation_runbook.this["sync-groups"].runtime_environment_name == "pwsh-74"
    error_message = "The runbook should reference its runtime environment."
  }

  assert {
    condition     = azurerm_automation_job_schedule.this["sync-daily"].runbook_name == "sync-groups"
    error_message = "The job schedule should link the runbook to the schedule."
  }

  assert {
    condition     = length(azurerm_automation_variable_string.this) == 1 && length(azurerm_automation_variable_int.this) == 1 && length(azurerm_automation_variable_bool.this) == 1
    error_message = "Variables should split into their typed resources."
  }

  assert {
    condition     = length(azurerm_automation_module.this) == 1
    error_message = "The module should be imported."
  }
}

run "rejects_runbook_with_no_body" {
  command = plan

  variables {
    runbooks = {
      "empty" = { runbook_type = "PowerShell" }
    }
  }

  expect_failures = [var.runbooks]
}

run "rejects_bad_variable_type" {
  command = plan

  variables {
    variables = {
      "x" = { type = "float", value = "1.5" }
    }
  }

  expect_failures = [var.variables]
}
