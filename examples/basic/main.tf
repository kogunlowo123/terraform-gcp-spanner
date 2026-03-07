###############################################################################
# Basic Example — Single-Node Regional Instance with Database
###############################################################################

module "spanner" {
  source = "../../"

  project_id = "my-gcp-project"

  instances = {
    "my-instance" = {
      display_name = "My Spanner Instance"
      config       = "regional-us-central1"
      num_nodes    = 1
    }
  }

  databases = {
    "my-database" = {
      instance                 = "my-instance"
      version_retention_period = "3600s"
      deletion_protection      = false
      ddl = [
        "CREATE TABLE Users (UserId INT64 NOT NULL, Name STRING(256), Email STRING(256)) PRIMARY KEY(UserId)",
      ]
    }
  }
}

output "instance_ids" {
  value = module.spanner.instance_ids
}

output "database_ids" {
  value = module.spanner.database_ids
}
