terraform {
  backend "gcs" {
    bucket  = "kin-analytics-infrastructure"
    prefix  = "terraform/snowflake-account/terraform.tfstate"
  }
}

provider "snowflake" {
  account = var.snowflake_account
  region = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  private_key_path = var.snowflake_private_key_path

  role = "ACCOUNTADMIN"
}
