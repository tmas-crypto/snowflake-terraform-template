# kf-snowflake-terraform

This is the terraform which manages our data pipeline infrastructure. This includes:

- Snowflake
    - Users
    - Roles
    - Databases & schemas
    - Integrations (storage)
    - Compute warehouses
    - Stages (Internal & External)
    - Misc. account settings (IP Whitelist)

# Initial reference for provider

Ref: https://github.com/Snowflake-Labs/terraform-provider-snowflake

# Manual Run From Local Machine

IMPORTANT USAGE NOTE: Before running, be certain team mates are aware of the changes that will be applied. This will need to be integrated into a CI/CD pipeline going forward.

## Setup

Create a terraform.tfvars in the base directory of this repo. Example of file contents:

```
snowflake_user = "your_email@kin.org"
snowflake_browser_auth = true
```

For GCP config, you need a profile called "analytics".

Create ~/.gcp/credentials:
```
[analytics]
access_key_id = ...
gcp_secret_access_key = [redacted]
```

## Applying a change to environment infra

Using dev as a reference env

```
cd kin_dev
terraform init
terraform plan -var-file=../terraform.tfvars
>>> Review plan and review with team
terraform apply -var-file=../terraform.tfvars
```

## Testing a change against all environments
`./build.sh` runs a plan for each env directory and results for each are stored in `/plan` for introspection or application.

## Manual steps in Snowflake

Monitor role
- Must ensure roles in grant exist before execution
- Due to tf limitations, grants for monitor role are required to be manually executed in Snowflake

GRANT IMPORT SHARE ON ACCOUNT TO SNOWFLAKE_MONITOR_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO SNOWFLAKE_MONITOR_ROLE;
