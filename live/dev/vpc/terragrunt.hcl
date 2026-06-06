include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(
    find_in_parent_folders("root.hcl")
  )
}

terraform {
  source = "git::https://github.com/<your-repo>/tf-module-vpc.git"
}

inputs = {
  tags = merge(
    local.root_config.locals.common_tags,
    {
      Env = "dev"
    }
  )
}