dependency "vpc" {
  config_path = "../vpc"
}

include {
    path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

terraform {
    source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"
}

inputs = {
    security_group_name = "allow-all"

    vpc_id = dependency.vpc.outputs.vpc_id

    tags = merge(
        local.root_config.locals.common_tags, 
        {
        Env      = "dev"
        ec2_type = "terragrunt-ec2"
        }
    )
}