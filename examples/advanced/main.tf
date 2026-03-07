###############################################################################
# Advanced Example — Autoscaling, CMEK, Backup Schedules
###############################################################################

module "spanner" {
  source = "../../"

  project_id = "my-gcp-project"

  labels = {
    team        = "platform"
    environment = "staging"
  }

  instances = {
    "staging-instance" = {
      display_name = "Staging Spanner Instance"
      config       = "regional-us-central1"
      autoscaling_config = {
        autoscaling_limits = {
          min_nodes = 1
          max_nodes = 5
        }
        autoscaling_targets = {
          high_priority_cpu_utilization_percent = 65
          storage_utilization_percent           = 80
        }
      }
    }
  }

  databases = {
    "orders-db" = {
      instance                 = "staging-instance"
      version_retention_period = "7200s"
      deletion_protection      = true
      encryption_config = {
        kms_key_name = "projects/my-gcp-project/locations/us-central1/keyRings/spanner-ring/cryptoKeys/spanner-key"
      }
      ddl = [
        "CREATE TABLE Orders (OrderId INT64 NOT NULL, CustomerId INT64, Amount FLOAT64, CreatedAt TIMESTAMP) PRIMARY KEY(OrderId)",
        "CREATE TABLE OrderItems (OrderId INT64 NOT NULL, ItemId INT64 NOT NULL, ProductId INT64, Quantity INT64) PRIMARY KEY(OrderId, ItemId), INTERLEAVE IN PARENT Orders ON DELETE CASCADE",
      ]
    }
  }

  backup_schedules = {
    "orders-daily-backup" = {
      instance  = "staging-instance"
      database  = "orders-db"
      cron      = "0 2 * * *"
      retention = "604800s"
    }
  }

  database_iam_bindings = {
    "orders-reader" = {
      instance = "staging-instance"
      database = "orders-db"
      role     = "roles/spanner.databaseReader"
      members  = ["serviceAccount:analytics@my-gcp-project.iam.gserviceaccount.com"]
    }
  }
}

output "instance_ids" {
  value = module.spanner.instance_ids
}

output "database_ids" {
  value = module.spanner.database_ids
}
