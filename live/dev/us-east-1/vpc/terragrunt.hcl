include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(
    find_in_parent_folders("root.hcl")
  )

  account_config = read_terragrunt_config(
    find_in_parent_folders("account.hcl")
  )

  region_config = read_terragrunt_config(
    find_in_parent_folders("region.hcl")
  )

  env_config = read_terragrunt_config(
    find_in_parent_folders("env.hcl")
  )
}

terraform {
  source = "git::https://github.com/Revanthsatyam/terragrunt-module-vpc.git"

  before_hook "before_plan" {
    commands     = ["plan"]

    execute      = [
      "powershell",
      "-Command",
      "Write-Host 'VPC plan is about to start...'"
    ]
  }

  after_hook "after_plan" {
    commands     = ["plan"]

    execute      = [
      "powershell",
      "-Command",
      "Write-Host 'VPC plan completed successfully!'"
    ]
  }

  extra_arguments "lock_timeout" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=20m"
    ]
  }  
}

prevent_destroy = false

inputs = {
  # tags = merge(
  #   local.root_config.locals.common_tags,
  #   {
  #     Env = "dev"
  #   }
  # )
  tags = merge(
    local.root_config.locals.common_tags,
    {
      Env       = local.env_config.locals.environment
      Region    = local.region_config.locals.aws_region
      AccountId = local.account_config.locals.aws_account_id
    }
  )
}