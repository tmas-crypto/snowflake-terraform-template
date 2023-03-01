locals {
  name = "kin_prod"

  tags = {
    Terraform   = "true"
    Environment = "kin_prod"
    Creater     = "terraform"
  }
}

module warehouse {
  source    = "../modules/data_warehouse"
  providers = {
    snowflake = snowflake
  }

  name      = local.name
  tags      = local.tags

  bi_service_name = "metabase-service-prod"
}
