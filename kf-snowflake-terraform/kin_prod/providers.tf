terraform {
  required_version = ">= 1.2.7"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.35"
    }
  }

  backend "gcs" {
    bucket  = "kin-analytics-infrastructure"
    prefix  = "terraform/kin-prod/terraform.tfstate"
  }
}

provider snowflake {
  account = var.snowflake_account
  region = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  private_key_path = var.snowflake_private_key_path

  role = "ACCOUNTADMIN"
}
