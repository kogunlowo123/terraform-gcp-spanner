###############################################################################
# Complete Example — All Spanner Features
###############################################################################

module "spanner" {
  source = "../../"

  project_id = "my-gcp-project"

  labels = {
    team        = "platform"
    environment = "production"
    managed_by  = "terraform"
  }

  # ---------- Instances ----------
  instances = {
    # Regional instance with autoscaling
    "prod-regional" = {
      display_name = "Production Regional Instance"
      config       = "regional-us-central1"
      autoscaling_config = {
        autoscaling_limits = {
          min_nodes = 3
          max_nodes = 10
        }
        autoscaling_targets = {
          high_priority_cpu_utilization_percent = 65
          storage_utilization_percent           = 80
        }
      }
      labels = {
        tier = "production"
      }
    }

    # Multi-region instance with fixed nodes
    "prod-multi-region" = {
      display_name = "Production Multi-Region Instance"
      config       = "nam-eur-asia1"
      num_nodes    = 3
      labels = {
        tier     = "production"
        topology = "multi-region"
      }
    }

    # Development instance with processing units
    "dev-instance" = {
      display_name     = "Development Instance"
      config           = "regional-us-central1"
      processing_units = 100
      force_destroy    = true
      labels = {
        tier = "development"
      }
    }
  }

  # ---------- Databases ----------
  databases = {
    # Production orders database with CMEK and PITR
    "orders-db" = {
      instance                 = "prod-regional"
      version_retention_period = "7d"
      deletion_protection      = true
      enable_drop_protection   = true
      encryption_config = {
        kms_key_name = "projects/my-gcp-project/locations/us-central1/keyRings/spanner/cryptoKeys/spanner-key"
      }
      ddl = [
        "CREATE TABLE Orders (OrderId INT64 NOT NULL, CustomerId INT64 NOT NULL, TotalAmount FLOAT64, Currency STRING(3), Status STRING(20), CreatedAt TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)) PRIMARY KEY(OrderId)",
        "CREATE TABLE OrderItems (OrderId INT64 NOT NULL, ItemId INT64 NOT NULL, ProductId INT64 NOT NULL, Quantity INT64, UnitPrice FLOAT64) PRIMARY KEY(OrderId, ItemId), INTERLEAVE IN PARENT Orders ON DELETE CASCADE",
        "CREATE INDEX OrdersByCustomer ON Orders(CustomerId)",
        "CREATE INDEX OrdersByStatus ON Orders(Status, CreatedAt DESC)",
      ]
    }

    # Global users database
    "users-db" = {
      instance                 = "prod-multi-region"
      version_retention_period = "3d"
      deletion_protection      = true
      ddl = [
        "CREATE TABLE Users (UserId INT64 NOT NULL, Email STRING(320) NOT NULL, DisplayName STRING(256), CreatedAt TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true), UpdatedAt TIMESTAMP OPTIONS (allow_commit_timestamp=true)) PRIMARY KEY(UserId)",
        "CREATE UNIQUE INDEX UsersByEmail ON Users(Email)",
        "CREATE TABLE UserSessions (UserId INT64 NOT NULL, SessionId STRING(128) NOT NULL, ExpiresAt TIMESTAMP NOT NULL) PRIMARY KEY(UserId, SessionId), INTERLEAVE IN PARENT Users ON DELETE CASCADE",
      ]
    }

    # PostgreSQL-dialect development database
    "dev-analytics" = {
      instance            = "dev-instance"
      database_dialect    = "POSTGRESQL"
      deletion_protection = false
    }
  }

  # ---------- Backup Schedules ----------
  backup_schedules = {
    "orders-hourly" = {
      instance  = "prod-regional"
      database  = "orders-db"
      cron      = "0 * * * *"
      retention = "86400s"
      encryption_config = {
        encryption_type = "CUSTOMER_MANAGED_ENCRYPTION"
        kms_key_name    = "projects/my-gcp-project/locations/us-central1/keyRings/spanner/cryptoKeys/backup-key"
      }
    }
    "orders-daily" = {
      instance  = "prod-regional"
      database  = "orders-db"
      cron      = "0 2 * * *"
      retention = "2592000s"
    }
    "users-daily" = {
      instance  = "prod-multi-region"
      database  = "users-db"
      cron      = "0 3 * * *"
      retention = "604800s"
    }
  }

  # ---------- Instance IAM Bindings ----------
  instance_iam_bindings = {
    "prod-regional-admin" = {
      instance = "prod-regional"
      role     = "roles/spanner.admin"
      members  = ["group:spanner-admins@example.com"]
    }
    "dev-instance-user" = {
      instance = "dev-instance"
      role     = "roles/spanner.databaseUser"
      members = [
        "group:developers@example.com",
        "serviceAccount:dev-app@my-gcp-project.iam.gserviceaccount.com",
      ]
    }
  }

  # ---------- Database IAM Bindings ----------
  database_iam_bindings = {
    "orders-app-writer" = {
      instance = "prod-regional"
      database = "orders-db"
      role     = "roles/spanner.databaseUser"
      members  = ["serviceAccount:order-service@my-gcp-project.iam.gserviceaccount.com"]
    }
    "orders-analytics-reader" = {
      instance = "prod-regional"
      database = "orders-db"
      role     = "roles/spanner.databaseReader"
      members  = ["serviceAccount:analytics@my-gcp-project.iam.gserviceaccount.com"]
      condition = {
        title       = "business-hours"
        description = "Read access during business hours only"
        expression  = "request.time.getHours('America/New_York') >= 9 && request.time.getHours('America/New_York') <= 17"
      }
    }
    "users-app-writer" = {
      instance = "prod-multi-region"
      database = "users-db"
      role     = "roles/spanner.databaseUser"
      members = [
        "serviceAccount:user-service@my-gcp-project.iam.gserviceaccount.com",
        "serviceAccount:auth-service@my-gcp-project.iam.gserviceaccount.com",
      ]
    }
  }
}

# ---------- Outputs ----------
output "instance_ids" {
  value = module.spanner.instance_ids
}

output "instance_states" {
  value = module.spanner.instance_states
}

output "database_ids" {
  value = module.spanner.database_ids
}

output "backup_schedule_ids" {
  value = module.spanner.backup_schedule_ids
}
