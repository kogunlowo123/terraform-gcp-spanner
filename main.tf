###############################################################################
# Spanner Instances
###############################################################################

resource "google_spanner_instance" "this" {
  for_each = var.instances

  name             = each.key
  config           = each.value.config
  display_name     = each.value.display_name
  processing_units = each.value.autoscaling_config == null ? each.value.processing_units : null
  num_nodes        = each.value.autoscaling_config == null ? each.value.num_nodes : null
  labels           = local.instance_labels[each.key]
  force_destroy    = each.value.force_destroy
  project          = var.project_id

  dynamic "autoscaling_config" {
    for_each = each.value.autoscaling_config != null ? [each.value.autoscaling_config] : []
    content {
      autoscaling_limits {
        min_processing_units = autoscaling_config.value.autoscaling_limits.min_processing_units
        max_processing_units = autoscaling_config.value.autoscaling_limits.max_processing_units
        min_nodes            = autoscaling_config.value.autoscaling_limits.min_nodes
        max_nodes            = autoscaling_config.value.autoscaling_limits.max_nodes
      }
      autoscaling_targets {
        high_priority_cpu_utilization_percent = autoscaling_config.value.autoscaling_targets.high_priority_cpu_utilization_percent
        storage_utilization_percent           = autoscaling_config.value.autoscaling_targets.storage_utilization_percent
      }
    }
  }
}

###############################################################################
# Spanner Databases
###############################################################################

resource "google_spanner_database" "this" {
  for_each = var.databases

  instance                 = each.value.instance
  name                     = each.key
  version_retention_period = each.value.version_retention_period
  ddl                      = each.value.ddl
  deletion_protection      = each.value.deletion_protection
  database_dialect         = each.value.database_dialect
  enable_drop_protection   = each.value.enable_drop_protection
  project                  = var.project_id

  dynamic "encryption_config" {
    for_each = each.value.encryption_config != null ? [each.value.encryption_config] : []
    content {
      kms_key_name = encryption_config.value.kms_key_name
    }
  }

  depends_on = [google_spanner_instance.this]
}

###############################################################################
# Backup Schedules
###############################################################################

resource "google_spanner_backup_schedule" "this" {
  for_each = var.backup_schedules

  instance = each.value.instance
  database = each.value.database
  project  = var.project_id

  retention_duration = each.value.retention

  spec {
    cron_spec {
      text = each.value.cron
    }
  }

  dynamic "encryption_config" {
    for_each = each.value.encryption_config != null ? [each.value.encryption_config] : []
    content {
      encryption_type = encryption_config.value.encryption_type
      kms_key_name    = encryption_config.value.kms_key_name
    }
  }

  depends_on = [google_spanner_database.this]
}

###############################################################################
# Instance IAM Bindings
###############################################################################

resource "google_spanner_instance_iam_member" "this" {
  for_each = local.instance_iam_members

  instance = each.value.instance
  role     = each.value.role
  member   = each.value.member
  project  = var.project_id

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

###############################################################################
# Database IAM Bindings
###############################################################################

resource "google_spanner_database_iam_member" "this" {
  for_each = local.database_iam_members

  instance = each.value.instance
  database = each.value.database
  role     = each.value.role
  member   = each.value.member
  project  = var.project_id

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
