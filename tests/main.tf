module "test" {
  source = "../"

  project_id = "test-project-id"

  labels = {
    environment = "test"
    managed_by  = "terraform"
  }

  instances = {
    "test-instance" = {
      display_name     = "Test Spanner Instance"
      config           = "regional-us-central1"
      processing_units = 100
      labels = {
        team = "platform"
      }
      force_destroy = true
    }
  }

  databases = {
    "test-database" = {
      instance                 = "test-instance"
      version_retention_period = "1h"
      database_dialect         = "GOOGLE_STANDARD_SQL"
      deletion_protection      = false
      ddl = [
        "CREATE TABLE Users (UserId INT64 NOT NULL, Name STRING(100)) PRIMARY KEY(UserId)",
      ]
    }
  }

  instance_iam_bindings = {
    "admin-access" = {
      instance = "test-instance"
      role     = "roles/spanner.admin"
      members  = ["serviceAccount:spanner-admin@test-project-id.iam.gserviceaccount.com"]
    }
  }

  database_iam_bindings = {
    "app-reader" = {
      instance = "test-instance"
      database = "test-database"
      role     = "roles/spanner.databaseReader"
      members  = ["serviceAccount:app-service@test-project-id.iam.gserviceaccount.com"]
    }
  }
}
