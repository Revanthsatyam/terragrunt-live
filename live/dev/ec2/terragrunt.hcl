dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock123"
  }
}

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
  source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"
}

inputs = {
  test_region = local.region_config.locals.aws_region

  security_group_name = "allow-all"

  vpc_id = dependency.vpc.outputs.vpc_id

  # tags = merge(
  #     local.root_config.locals.common_tags, 
  #     {
  #     Env      = "dev"
  #     ec2_type = "terragrunt-ec2"
  #     }
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