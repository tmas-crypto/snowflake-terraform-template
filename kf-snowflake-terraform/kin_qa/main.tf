locals {
  name = "kin_qa"

  tags = {
    Terraform   = "true"
    Environment = "kin_qa"
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

  bi_service_name = "metabase-service-qa"
}
