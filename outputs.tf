output "instance_ids" {
  description = "Map of instance names to their fully-qualified resource IDs."
  value       = { for k, v in google_spanner_instance.this : k => v.id }
}

output "instance_names" {
  description = "Map of instance names to their short names."
  value       = { for k, v in google_spanner_instance.this : k => v.name }
}

output "instance_states" {
  description = "Map of instance names to their current state."
  value       = { for k, v in google_spanner_instance.this : k => v.state }
}

output "database_ids" {
  description = "Map of database names to their fully-qualified resource IDs."
  value       = { for k, v in google_spanner_database.this : k => v.id }
}

output "database_names" {
  description = "Map of database names to their short names."
  value       = { for k, v in google_spanner_database.this : k => v.name }
}

output "database_states" {
  description = "Map of database names to their current state."
  value       = { for k, v in google_spanner_database.this : k => v.state }
}

output "backup_schedule_ids" {
  description = "Map of backup schedule logical names to their resource IDs."
  value       = { for k, v in google_spanner_backup_schedule.this : k => v.id }
}

output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}
