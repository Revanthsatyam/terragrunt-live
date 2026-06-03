include {
    path = find_in_parent_folders()
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

terraform {
    source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"
}

inputs = {
    security_group_name = "allow-all"

    tags = merge(
        local.root_config.locals.common_tags, 
        {
        Env     = "dev"
        Project = "terragrunt-ec2"
        }
    )
}