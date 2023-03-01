//resource snowflake_network_policy policy {
//  name              = "access-policy"
//
//  allowed_ip_list   = [
//    "24.246.46.175", # Place your home IP here for emergencies
//    "TBD",  # Consider a NAT GW equivalent in google cloud for emergency access
//
//    # Metabase
//    "18.207.81.126",
//    "3.211.20.157",
//    "50.17.234.169"
//    # Shakudo
//    # Kin dev portal
//  ]
//
//  blocked_ip_list   = []
//}

//resource snowflake_network_policy_attachment attach {
//  network_policy_name   = snowflake_network_policy.policy.name
//  set_for_account       = true
//}

locals {
  rsa_public_key = file("~/.ssh/snowflake_tf_snow_key.pub")
  rsa_public_key_lines = split("\n", local.rsa_public_key)
}

resource snowflake_user terraform {
  name = "terraform"
  comment = "Terraform service user"
  default_role = "SYSADMIN"
  rsa_public_key = join("", slice(local.rsa_public_key_lines, 1, length(local.rsa_public_key_lines) - 2))
}
