variable snowflake_user {
  type      = string
  sensitive = true
}
variable snowflake_password {
  type      = string
  sensitive = true
  default   = null
}
variable snowflake_account {
  type      = string
  default   = "EN81601"
}
variable snowflake_region {
  type      = string
  default   = "US-CENTRAL1.GCP"
}
variable snowflake_private_key_path {
  type      = string
  default   = null
}
variable snowflake_browser_auth {
  type      = string
  default   = false
}
