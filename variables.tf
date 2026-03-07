###############################################################################
# General
###############################################################################

variable "project_id" {
  description = "The GCP project ID where Spanner resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "labels" {
  description = "Common labels to apply to all Spanner resources."
  type        = map(string)
  default     = {}
}

###############################################################################
# Spanner Instances
###############################################################################

variable "instances" {
  description = <<-EOT
    Map of Spanner instances to create.
    Key is the instance name.
    EOT
  type = map(object({
    display_name     = string
    config           = string
    processing_units = optional(number, null)
    num_nodes        = optional(number, null)
    labels           = optional(map(string), {})
    force_destroy    = optional(bool, false)

    autoscaling_config = optional(object({
      autoscaling_limits = object({
        min_processing_units = optional(number, null)
        max_processing_units = optional(number, null)
        min_nodes            = optional(number, null)
        max_nodes            = optional(number, null)
      })
      autoscaling_targets = optional(object({
        high_priority_cpu_utilization_percent = optional(number, 65)
        storage_utilization_percent           = optional(number, 90)
      }), {})
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.instances :
      !(v.processing_units != null && v.num_nodes != null)
    ])
    error_message = "Specify either processing_units or num_nodes, not both."
  }
}

###############################################################################
# Spanner Databases
###############################################################################

variable "databases" {
  description = <<-EOT
    Map of Spanner databases to create.
    Key is the database name.
    EOT
  type = map(object({
    instance                 = string
    version_retention_period = optional(string, "1h")
    ddl                      = optional(list(string), [])
    deletion_protection      = optional(bool, true)
    database_dialect         = optional(string, "GOOGLE_STANDARD_SQL")
    enable_drop_protection   = optional(bool, false)

    encryption_config = optional(object({
      kms_key_name = string
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.databases :
      contains(["GOOGLE_STANDARD_SQL", "POSTGRESQL"], v.database_dialect)
    ])
    error_message = "database_dialect must be GOOGLE_STANDARD_SQL or POSTGRESQL."
  }
}

###############################################################################
# Backup Schedules
###############################################################################

variable "backup_schedules" {
  description = <<-EOT
    Map of Spanner database backup schedules.
    Key is a logical name for the backup schedule.
    EOT
  type = map(object({
    instance  = string
    database  = string
    cron      = string
    retention = string

    encryption_config = optional(object({
      encryption_type = string
      kms_key_name    = optional(string, null)
    }), null)
  }))
  default = {}
}

###############################################################################
# Instance IAM Bindings
###############################################################################

variable "instance_iam_bindings" {
  description = <<-EOT
    Map of IAM bindings for Spanner instances.
    Key is a logical name.
    EOT
  type = map(object({
    instance = string
    role     = string
    members  = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

###############################################################################
# Database IAM Bindings
###############################################################################

variable "database_iam_bindings" {
  description = <<-EOT
    Map of IAM bindings for Spanner databases.
    Key is a logical name.
    EOT
  type = map(object({
    instance = string
    database = string
    role     = string
    members  = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}
