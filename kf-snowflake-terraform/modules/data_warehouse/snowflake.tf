variable name {
  type = string
}
variable data_retention_time_in_days {
  type      = number
  default   = 1
}
variable tags {
  type = map
}
variable bi_service_name {
  type      = string
  default   = null
}
variable shakudo_parent_role {
  type = string
  default = "SYSADMIN"
}

locals {
  snow_name = upper(replace(var.name, "-", "_"))
}

//
// BI User
//

module bi_service_access {
  source    = "../bi_service_access"
  providers = {
    snowflake   = snowflake
  }
  name      = var.bi_service_name
  tags      = var.tags
}

//
// Warehouse, Database and common schema
//

resource snowflake_warehouse shakudo {
  name            = "${local.snow_name}_SHAKUDO_WH"
  comment         = "${var.name} shakudo transform warehouse"
  auto_suspend    = 60
  warehouse_size  = "xsmall"
}

resource snowflake_database shakudo {
  name                        = "${local.snow_name}_DB"
  data_retention_time_in_days = var.data_retention_time_in_days
}

resource snowflake_schema admin_schema {
  name                        = "ADMIN"
  database                    = snowflake_database.shakudo.name
  comment                     = "Admin schema for common objects in database. FFs and Seqs"
}

//
// User and Roles
//

resource snowflake_role shakudo {
  name      = "${local.snow_name}_SHAKUDO_ROLE"
  comment   = "${var.name} shakudo transform role"
}

# May want to consider adding GCP password manager here

resource random_password shakudo_seed_password {
  length    = 24
  special   = true
}

resource snowflake_user shakudo {
  name                  = "${local.snow_name}_SHAKUDO_USER"
  comment               = "${var.name} shakudo user"
  default_role          = snowflake_role.shakudo.name
  default_warehouse     = snowflake_warehouse.shakudo.name
  password              = random_password.shakudo_seed_password.result
  must_change_password  = false
}

resource snowflake_role_grants shakudo {
  role_name = snowflake_role.shakudo.name

  # Double check this
  roles     = length(module.bi_service_access) == 0 ? [ var.shakudo_parent_role ] : [ var.shakudo_parent_role, module.bi_service_access.role_name ]
  users     = [ snowflake_user.shakudo.name ]
}

//
// Permission grants
//

resource snowflake_warehouse_grant shakudo {
  for_each          = toset(["OPERATE", "USAGE"])

  warehouse_name    = snowflake_warehouse.shakudo.name
  privilege         = each.value

  roles             = [ snowflake_role.shakudo.name ]

  with_grant_option = false
}

resource snowflake_database_grant shakudo {
  for_each          = toset(["USAGE", "MODIFY", "MONITOR", "CREATE SCHEMA"])

  database_name     = snowflake_database.shakudo.name
  privilege         = each.value

  roles             = [ snowflake_role.shakudo.name ]

  with_grant_option  = false
}

resource snowflake_schema_grant shakudo_future {
  for_each          = toset(["USAGE", "MODIFY", "MONITOR", "CREATE VIEW", "CREATE MATERIALIZED VIEW", "CREATE TABLE", "CREATE SEQUENCE", "CREATE FILE FORMAT"])

  database_name     = snowflake_database.shakudo.name
  privilege         = each.value
  roles             = [ snowflake_role.shakudo.name ]

  on_future         = true
  with_grant_option  = false
}

// All future files formats in db are granted privilege to roles
resource snowflake_file_format_grant shakudo_file_format {
  database_name     = snowflake_database.shakudo.name
  schema_name       = snowflake_schema.admin_schema.name

  privilege         = "OWNERSHIP"
  roles             = [ snowflake_role.shakudo.name ]

  on_future         = true
  with_grant_option = false
}

resource snowflake_sequence_grant grant {
  database_name = snowflake_database.shakudo.name
  schema_name = snowflake_schema.admin_schema.name

  privilege = "OWNERSHIP"
  roles = [ snowflake_role.shakudo.name ]

  on_future = true
  with_grant_option = false
}

//
// Outputs
//

output database_name {
  value = snowflake_database.shakudo.name
}

output role_name {
  value = snowflake_role.shakudo.name
}

# We output here as we need to manually send this to Shakudo right now. No Kin SSM integration
output user_password {
  value = snowflake_user.shakudo.password
  sensitive = true
}
