variable "credentials" {
  description = "Automation credentials (username/password pairs runbooks retrieve) keyed by name."
  type = map(object({
    username    = string
    password    = string
    description = optional(string)
  }))
  default   = {}
  sensitive = true
}

variable "encryption" {
  description = "Customer-managed key encryption. Null uses platform-managed keys."
  type = object({
    key_vault_key_id          = string
    key_source                = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default = null
}

variable "identity" {
  description = "Account identity. SystemAssigned by default; pass UserAssigned (or the combined type) with identity_ids to bring your own."
  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string))
  })
  default = {}
}

variable "job_schedules" {
  description = <<-DESC
    Job schedules keyed by an arbitrary name, each linking a runbook to a schedule (both must be
    defined above or already exist). parameters passes runbook parameters; run_on targets a hybrid
    worker group.
  DESC
  type = map(object({
    runbook_name  = string
    schedule_name = string
    parameters    = optional(map(string))
    run_on        = optional(string)
  }))
  default = {}
}

variable "local_authentication_enabled" {
  description = "Whether key-based (local) authentication is allowed. Off is the stronger posture (AAD only)."
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region for the account and its child resources."
  type        = string
}

variable "modules" {
  description = "PowerShell modules keyed by name, imported from a package URI (e.g. the PowerShell Gallery nupkg)."
  type = map(object({
    uri = string
    hash = optional(object({
      algorithm = string
      value     = string
    }))
  }))
  default = {}
}

variable "name" {
  description = "Name of the automation account."
  type        = string
}

variable "powershell72_modules" {
  description = "PowerShell 7.2 modules keyed by name, imported from a package URI (e.g. a PowerShell Gallery nupkg). Use this for modern 7.x runbooks and runtime environments (e.g. LibreDevOpsHelpers)."
  type = map(object({
    uri = string
    hash = optional(object({
      algorithm = string
      value     = string
    }))
    tags = optional(map(string))
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Whether the account is reachable over the public internet."
  type        = bool
  default     = true
}

variable "resource_group_id" {
  description = "Id of the resource group; the module parses the name from it."
  type        = string
}

variable "runbooks" {
  description = <<-DESC
    Runbooks keyed by name. runbook_type is one of PowerShell, PowerShell72, Python2, Python3,
    GraphPowerShell, GraphPowerShellWorkflow, or Script. Provide the body inline with `content`
    or from a URI with `publish_content_link`. Attach a runtime_environment_name for the modern
    runtime model. Logging defaults off (log_progress/log_verbose).
  DESC
  type = map(object({
    runbook_type             = string
    content                  = optional(string)
    description              = optional(string)
    log_progress             = optional(bool, false)
    log_verbose              = optional(bool, false)
    log_activity_trace_level = optional(number)
    runtime_environment_name = optional(string)
    publish_content_link = optional(object({
      uri     = string
      version = optional(string)
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    }))
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.runbooks) : r.content != null || r.publish_content_link != null])
    error_message = "Each runbook needs its body: set content (inline) or publish_content_link (from a URI)."
  }
}

variable "runtime_environments" {
  description = <<-DESC
    Runtime environments keyed by name (the modern replacement for global modules: a per-runbook
    language and version, e.g. PowerShell 7.2 or Python 3.10). runtime_language and runtime_version
    are required; runtime_default_packages pins base package versions. Azure caps per-resource tags
    at 3, so tags here are not merged with the account tags (supply at most 3).
  DESC
  type = map(object({
    runtime_language         = string
    runtime_version          = string
    description              = optional(string)
    runtime_default_packages = optional(map(string))
    tags                     = optional(map(string))
  }))
  default = {}
}

variable "schedules" {
  description = <<-DESC
    Schedules keyed by name. frequency is OneTime, Minute, Hour, Day, Week, or Month; interval is
    how many of those between runs (omit for OneTime). week_days/month_days/monthly_occurrence
    refine Week/Month schedules.
  DESC
  type = map(object({
    frequency   = string
    interval    = optional(number)
    start_time  = optional(string)
    expiry_time = optional(string)
    timezone    = optional(string)
    description = optional(string)
    week_days   = optional(list(string))
    month_days  = optional(list(number))
    monthly_occurrence = optional(object({
      day        = string
      occurrence = number
    }))
  }))
  default = {}
}

variable "sku_name" {
  description = "Automation account SKU: Basic (default) or Free."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags applied to the account and its taggable child resources."
  type        = map(string)
  default     = {}
}

variable "variables" {
  description = <<-DESC
    Automation variables keyed by name. `type` selects the typed resource (string, int, bool,
    datetime, or object); `value` is the value (a string for object/datetime, encoded as the
    resource expects). Set encrypted = true for secrets.
  DESC
  type = map(object({
    type        = string
    value       = optional(string)
    description = optional(string)
    encrypted   = optional(bool)
  }))
  default = {}

  validation {
    condition     = alltrue([for v in values(var.variables) : contains(["string", "int", "bool", "datetime", "object"], v.type)])
    error_message = "variable type must be one of string, int, bool, datetime, or object."
  }
}
