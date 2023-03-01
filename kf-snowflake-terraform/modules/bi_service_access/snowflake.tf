variable name {
  type = string
}
variable tags {
  type = map
}

locals {
  snow_name = upper(replace(var.name, "-", "_"))
}

resource snowflake_warehouse metabase {
  name              = "${local.snow_name}_WH"
  comment           = "${var.name} warehouse for Metabase."
  auto_suspend      = 60
  warehouse_size    = "xsmall"
}

resource snowflake_role metabase {
  name      = "${local.snow_name}_ROLE"
  comment   = "${var.name} role for Metabase."
}

resource random_password metabase_password_seed {
  length    = 24
  special   = true
}

resource snowflake_user metabase {
  name                  = local.snow_name
  comment               = "${var.name} service user for Metabase"
  default_role          = snowflake_role.metabase.name
  default_warehouse     = snowflake_warehouse.metabase.name
  password              = random_password.metabase_password_seed.result
  must_change_password  = false
}

resource snowflake_role_grants metabase {
  role_name = snowflake_role.metabase.name
  roles     = [ "SYSADMIN" ]
  users     = [ snowflake_user.metabase.name ]
}

resource snowflake_warehouse_grant metabase {
  for_each          = toset(["OPERATE", "USAGE"])

  warehouse_name    = snowflake_warehouse.metabase.name
  privilege         = each.value

  roles             = [
    snowflake_role.metabase.name
  ]

  with_grant_option = false
}

output role_name {
  value = snowflake_role.metabase.name
}

output user {
  value = snowflake_user.metabase.name
}

output user_password {
  value     = random_password.metabase_password_seed.result
  sensitive = true
}
