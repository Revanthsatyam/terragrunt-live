include {
    path = find_in_parent_folders()
}

terraform {
    source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"
}

inputs = {
    security_group_name = "allow-all"

    tags = merge(
        local.common_tags, 
        {
        Env     = "dev"
        Project = "terragrunt-ec2"
        }
    )
}