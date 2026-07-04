<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Automation Account

Terraform module for Azure Automation, in the Libre DevOps style: fast to get going, secure by
default, flexible when it matters. One account plus the child resources you actually run, each a
tidy map.

[![CI](https://github.com/libre-devops/terraform-azurerm-automation-account/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-automation-account/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-automation-account?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-automation-account/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-automation-account)](./LICENSE)

---

## Overview

```hcl
module "automation_account" {
  source  = "libre-devops/automation-account/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-dev-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  name = "aa-ldo-uks-dev-001"
}
```

That single entry stands up a Basic account with a system-assigned identity. Every knob is an
explicit override.

- **One account, children as maps.** The account is top-level (no tangled map-of-accounts); the
  things you actually run, runbooks, schedules, runtime environments, variables, credentials, and
  modules, are each a map keyed by name, cross-referenced by name so a `job_schedule` just names
  the runbook and schedule it binds.
- **Runbooks your way.** Provide the body inline with `content` or from a URI with
  `publish_content_link`, and attach a `runtime_environment` (the modern PowerShell/Python
  language-and-version model) rather than wrangling global modules; a validation makes sure every
  runbook actually has a body.
- **Typed variables, one map.** `variables` is a single map where each entry's `type` (string,
  int, bool, datetime, or object) routes it to the right typed resource; set `encrypted = true`
  for secrets.
- **Secure options.** System or user assigned identity, customer-managed key `encryption`,
  `public_network_access_enabled`, and `local_authentication_enabled` are all exposed.

Deliberately scoped: the account plus the productive child resources, not the full DSC,
hybrid-worker, watcher, source-control, and software-update-configuration surface (compose those
alongside if you need them).

## Examples

- [`examples/minimal`](./examples/minimal) - a Basic account, applied and destroyed in CI.
- [`examples/complete`](./examples/complete) - a runtime environment, an inline and a URI runbook,
  a schedule, a job schedule linking them, typed variables, and a gallery module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) | resource |
| [azurerm_automation_job_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_module.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_module) | resource |
| [azurerm_automation_powershell72_module.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_powershell72_module) | resource |
| [azurerm_automation_runbook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_runtime_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runtime_environment) | resource |
| [azurerm_automation_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_variable_bool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_bool) | resource |
| [azurerm_automation_variable_datetime.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_datetime) | resource |
| [azurerm_automation_variable_int.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_int) | resource |
| [azurerm_automation_variable_object.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_object) | resource |
| [azurerm_automation_variable_string.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials"></a> [credentials](#input\_credentials) | Automation credentials (username/password pairs runbooks retrieve) keyed by name. | <pre>map(object({<br/>    username    = string<br/>    password    = string<br/>    description = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Customer-managed key encryption. Null uses platform-managed keys. | <pre>object({<br/>    key_vault_key_id          = string<br/>    key_source                = optional(string)<br/>    user_assigned_identity_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Account identity. SystemAssigned by default; pass UserAssigned (or the combined type) with identity\_ids to bring your own. | <pre>object({<br/>    type         = optional(string, "SystemAssigned")<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `{}` | no |
| <a name="input_job_schedules"></a> [job\_schedules](#input\_job\_schedules) | Job schedules keyed by an arbitrary name, each linking a runbook to a schedule (both must be<br/>defined above or already exist). parameters passes runbook parameters; run\_on targets a hybrid<br/>worker group. | <pre>map(object({<br/>    runbook_name  = string<br/>    schedule_name = string<br/>    parameters    = optional(map(string))<br/>    run_on        = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether key-based (local) authentication is allowed. Off is the stronger posture (AAD only). | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the account and its child resources. | `string` | n/a | yes |
| <a name="input_modules"></a> [modules](#input\_modules) | PowerShell modules keyed by name, imported from a package URI (e.g. the PowerShell Gallery nupkg). | <pre>map(object({<br/>    uri = string<br/>    hash = optional(object({<br/>      algorithm = string<br/>      value     = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the automation account. | `string` | n/a | yes |
| <a name="input_powershell72_modules"></a> [powershell72\_modules](#input\_powershell72\_modules) | PowerShell 7.2 modules keyed by name, imported from a package URI (e.g. a PowerShell Gallery nupkg). Use this for modern 7.x runbooks and runtime environments (e.g. LibreDevOpsHelpers). | <pre>map(object({<br/>    uri = string<br/>    hash = optional(object({<br/>      algorithm = string<br/>      value     = string<br/>    }))<br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the account is reachable over the public internet. | `bool` | `true` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Id of the resource group; the module parses the name from it. | `string` | n/a | yes |
| <a name="input_runbooks"></a> [runbooks](#input\_runbooks) | Runbooks keyed by name. runbook\_type is one of PowerShell, PowerShell72, Python2, Python3,<br/>GraphPowerShell, GraphPowerShellWorkflow, or Script. Provide the body inline with `content`<br/>or from a URI with `publish_content_link`. Attach a runtime\_environment\_name for the modern<br/>runtime model. Logging defaults off (log\_progress/log\_verbose). | <pre>map(object({<br/>    runbook_type             = string<br/>    content                  = optional(string)<br/>    description              = optional(string)<br/>    log_progress             = optional(bool, false)<br/>    log_verbose              = optional(bool, false)<br/>    log_activity_trace_level = optional(number)<br/>    runtime_environment_name = optional(string)<br/>    publish_content_link = optional(object({<br/>      uri     = string<br/>      version = optional(string)<br/>      hash = optional(object({<br/>        algorithm = string<br/>        value     = string<br/>      }))<br/>    }))<br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_runtime_environments"></a> [runtime\_environments](#input\_runtime\_environments) | Runtime environments keyed by name (the modern replacement for global modules: a per-runbook<br/>language and version, e.g. PowerShell 7.2 or Python 3.10). runtime\_language and runtime\_version<br/>are required; runtime\_default\_packages pins base package versions. | <pre>map(object({<br/>    runtime_language         = string<br/>    runtime_version          = string<br/>    description              = optional(string)<br/>    runtime_default_packages = optional(map(string))<br/>    tags                     = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Schedules keyed by name. frequency is OneTime, Minute, Hour, Day, Week, or Month; interval is<br/>how many of those between runs (omit for OneTime). week\_days/month\_days/monthly\_occurrence<br/>refine Week/Month schedules. | <pre>map(object({<br/>    frequency   = string<br/>    interval    = optional(number)<br/>    start_time  = optional(string)<br/>    expiry_time = optional(string)<br/>    timezone    = optional(string)<br/>    description = optional(string)<br/>    week_days   = optional(list(string))<br/>    month_days  = optional(list(number))<br/>    monthly_occurrence = optional(object({<br/>      day        = string<br/>      occurrence = number<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Automation account SKU: Basic (default) or Free. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the account and its taggable child resources. | `map(string)` | `{}` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Automation variables keyed by name. `type` selects the typed resource (string, int, bool,<br/>datetime, or object); `value` is the value (a string for object/datetime, encoded as the<br/>resource expects). Set encrypted = true for secrets. | <pre>map(object({<br/>    type        = string<br/>    value       = optional(string)<br/>    description = optional(string)<br/>    encrypted   = optional(bool)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account"></a> [automation\_account](#output\_automation\_account) | The full automation account object. Sensitive as a whole because it carries the DSC/registration keys; the id, name, and identity outputs alongside stay plain for composition. |
| <a name="output_automation_account_id"></a> [automation\_account\_id](#output\_automation\_account\_id) | The automation account id. |
| <a name="output_automation_account_name"></a> [automation\_account\_name](#output\_automation\_account\_name) | The automation account name. |
| <a name="output_identity_principal_ids"></a> [identity\_principal\_ids](#output\_identity\_principal\_ids) | The account's { system\_assigned } identity principal id (null where absent). |
| <a name="output_runbook_ids"></a> [runbook\_ids](#output\_runbook\_ids) | Map of runbook name to id. |
| <a name="output_runtime_environment_ids"></a> [runtime\_environment\_ids](#output\_runtime\_environment\_ids) | Map of runtime environment name to id. |
| <a name="output_schedule_ids"></a> [schedule\_ids](#output\_schedule\_ids) | Map of schedule name to id. |
<!-- END_TF_DOCS -->
