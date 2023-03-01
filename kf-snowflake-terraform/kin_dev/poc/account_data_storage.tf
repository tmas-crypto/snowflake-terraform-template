// Note: Tucking this here for now. Needs to be account level

resource snowflake_storage_integration kin_google_cloud {
  name = "KIN_GCP_STORAGE_INTEGRATION"
  comment = "Kin GCP Storage Integration"
  type = "EXTERNAL_STAGE"

  enabled = true
  storage_allowed_locations = [
    "gcs://kin-snowflake-external-stage"
  ]
  storage_provider = "GCS"
}

resource snowflake_schema kin_gcs_external_storage_schema {
  database  = "KIN_EXTERNAL_DATA_DB"
  name      = "EXTERNAL_KIN_GCS"
  comment   = "Schema containing external tables for data in Kin GCS"

  # Setting this to transient is safe since the tables can be easily recreated on top of GCS
  is_transient          = true
  is_managed            = false
  data_retention_days   = 1
}

resource snowflake_schema_grant external_storage_schema_grants {
  database_name = "KIN_EXTERNAL_DATA_DB"
  schema_name   = snowflake_schema.kin_gcs_external_storage_schema.name

  privilege     = "USAGE"
  roles = [
    "PUBLIC"
  ]
}

resource snowflake_stage kin_gcs_external_stage {
  name                  = "KIN_GCS_EXTERNAL_DATA_STAGE"
  url                   = "gcs://kin-snowflake-external-stage"
  database              = "KIN_EXTERNAL_DATA_DB"
  schema                = snowflake_schema.kin_gcs_external_storage_schema.name
  storage_integration   = snowflake_storage_integration.kin_google_cloud.name
}

resource snowflake_stage_grant grant {
  database_name = "KIN_EXTERNAL_DATA_DB"
  schema_name   = snowflake_schema.kin_gcs_external_storage_schema.name
  stage_name    = snowflake_stage.kin_gcs_external_stage.name

  privilege     = "USAGE"
  roles         = [
    "PUBLIC"
  ]
}
