locals {
    # aws_region = "us-east-1"
    region_config = read_terragrunt_config(
        find_in_parent_folders("region.hcl")
    )

    aws_region = local.region_config.locals.aws_region

    common_tags = {
        ManagedBy = "Terragrunt"
        Project   = "Learning-Terragrunt"
    }
}

remote_state {
    backend = "s3"

    generate = {
        path      = "backend.tf"
        if_exists = "overwrite"
    }

    config = {
        bucket         = "revanth-terraform-state-2026"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-locks"
        encrypt        = true
    }
}

generate "provider" {
    path      = "provider.tf"
    if_exists = "overwrite"

    contents = <<EOF
        provider "aws" {
            region = "${local.aws_region}"
        }
    EOF
}