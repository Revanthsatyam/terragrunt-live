terraform {
    source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"
}

inputs = {
    security_group_name = "allow-all"

    tags = {
        Env     = "dev"
        Project = "terragrunt-ec2"
    }
}