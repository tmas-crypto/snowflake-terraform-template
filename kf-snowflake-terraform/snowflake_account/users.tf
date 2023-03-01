# Create accounts for people with different grains of access

locals {
  account_admins = {
    "admin"  = "admin@email.com"
  }

  developers = {
    "adev"  = "adev@email.com"
  }
}

resource snowflake_user developer {
  for_each          = merge(local.account_admins, local.developers)
  login_name        = each.value
  name              = each.key
  email             = each.value
  default_role      = "DEVELOPER"
  default_warehouse = "COMPUTE_WH"
}
