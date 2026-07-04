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
