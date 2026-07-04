# The module's productive surface: a PowerShell 7.4 runtime environment, an inline runbook bound
# to it and a second runbook pulled from a URI, a daily schedule, a job schedule linking the
# runbook to it, typed automation variables, and a module imported from the PowerShell Gallery.
# Applied then destroyed in one CI run.
locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  aa_name  = "aa-${var.short}-${var.loc}-${terraform.workspace}-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-automation-account" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

module "automation_account" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  name = local.aa_name

  identity = { type = "SystemAssigned" }

  runtime_environments = {
    "pwsh-74" = { runtime_language = "PowerShell", runtime_version = "7.4" }
  }

  runbooks = {
    "hello-world" = {
      runbook_type             = "PowerShell72"
      runtime_environment_name = "pwsh-74"
      description              = "A trivial runbook that logs a greeting via the Libre DevOps helpers."
      content                  = <<-PS
        Import-Module LibreDevOpsHelpers
        Write-LdoLog -Level INFO -Message 'Hello from Azure Automation'
      PS
    }
  }

  # The shared Libre DevOps PowerShell helper layer, imported so 7.x runbooks can Import-Module it.
  powershell72_modules = {
    "LibreDevOpsHelpers" = {
      uri = "https://www.powershellgallery.com/api/v2/package/LibreDevOpsHelpers/2.3.1"
    }
  }

  schedules = {
    "daily-2am" = {
      frequency   = "Day"
      interval    = 1
      timezone    = "Etc/UTC"
      description = "Runs once a day."
    }
  }

  job_schedules = {
    "hello-daily" = {
      runbook_name  = "hello-world"
      schedule_name = "daily-2am"
    }
  }

  variables = {
    "Environment" = { type = "string", value = "dev" }
    "MaxRetries"  = { type = "int", value = "5" }
    "DryRun"      = { type = "bool", value = "true" }
  }

  modules = {
    "Az.Accounts" = { uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts" }
  }
}

output "automation_account_id" {
  value = module.automation_account.automation_account_id
}

output "runbook_ids" {
  value = module.automation_account.runbook_ids
}

output "resource_group_name" {
  value = local.rg_name
}
