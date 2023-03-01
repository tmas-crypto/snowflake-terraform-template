resource snowflake_role developer {
  name = "DEVELOPER"
}

resource snowflake_role_grants developer {
  role_name = snowflake_role.developer.name
  roles     = [
    "SYSADMIN"
  ]
  users     = keys(local.developers)
}

resource snowflake_role_grants admin {
  role_name = "ACCOUNTADMIN"
  users = concat(
    [ snowflake_user.terraform.name ],
    keys(local.account_admins)
  )
}

//
// Monitor Role
// Run in Snowflake manually to grant account usage to monitor role
// GRANT IMPORT SHARE ON ACCOUNT TO SNOWFLAKE_MONITOR_ROLE;
// GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO SNOWFLAKE_MONITOR_ROLE;
//

resource snowflake_role snowflake_monitor {
  name      = "SNOWFLAKE_MONITOR_ROLE"
  comment   = "Role for monitoring in Snowflaker"
}

//
// Grants notes:
// Ensure that the roles in grant list exist from env terraform apply
// Comment roles out if they don't show up in Snowflake
//

# This is commented out right now since there isn't a need for this detail in metabase
//resource snowflake_role_grants monitor {
//  role_name = "SNOWFLAKE_MONITOR_ROLE"
//  roles = [
//    "METABASE_READ_ONLY"
//  ]
//}
