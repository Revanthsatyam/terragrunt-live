
# Terragrunt Cheat Sheet

> [!IMPORTANT]
> **Goal:** 5-minute revision before interviews or before starting a Terragrunt project.

---

# 📁 Repository Structure

```text
terragrunt-live/
│
├── root.hcl                          # Shared backend, provider & common configuration
│
└── live/
    ├── dev/
    │   ├── account.hcl               # AWS Account specific values
    │   ├── env.hcl                   # Environment specific values
    │   │
    │   └── us-east-1/
    │       ├── region.hcl            # Region specific values
    │       │
    │       ├── vpc/
    │       │   └── terragrunt.hcl
    │       │
    │       └── ec2/
    │           └── terragrunt.hcl
    │
    └── prod/
```

| File | Purpose |
|------|---------|
| `root.hcl` | Shared backend, provider and common configuration |
| `account.hcl` | AWS Account specific values |
| `env.hcl` | Environment specific values |
| `region.hcl` | Region specific values |
| `terragrunt.hcl` | Service specific configuration |

> [!TIP]
> **Remember**
> - Terraform modules contain infrastructure code.
> - Terragrunt contains configuration.

---

# ⚙️ root.hcl

```hcl
locals {
  aws_region = "us-east-1"

  common_tags = {
    ManagedBy = "Terragrunt"
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
  region = "us-east-1"
}
EOF
}
```

| Block | What it does |
|------|---------------|
| `locals` | Store reusable values |
| `remote_state` | Configure S3 backend automatically |
| `generate` | Create provider/backend files automatically |
| `path_relative_to_include()` | Creates a unique tfstate path for each module |

> [!NOTE]
> **Real World Use**
>
> Keep backend, provider and common configuration in one place instead of duplicating it across every module.

> [!TIP]
> **Remember**
>
> `path_relative_to_include()` prevents every module from writing to the same state file.

---

# 🚀 terragrunt.hcl

```hcl
include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  account_config = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_config = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "git::https://github.com/Revanthsatyam/tf-module-ec2.git"

  before_hook "before_plan" {
    commands = ["plan"]
    execute = ["powershell","-Command","Write-Host 'VPC plan is about to start...'"]
  }

  after_hook "after_plan" {
    commands = ["plan"]
    execute = ["powershell","-Command","Write-Host 'VPC plan completed successfully!'"]
  }

  extra_arguments "lock_timeout" {
    commands = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock123"
  }
}

prevent_destroy = false

inputs = {
  test_region = local.region_config.locals.aws_region
  security_group_name = "allow-all"
  vpc_id = dependency.vpc.outputs.vpc_id

  tags = merge(
    local.root_config.locals.common_tags,
    {
      Env       = local.env_config.locals.environment
      Region    = local.region_config.locals.aws_region
      AccountId = local.account_config.locals.aws_account_id
    }
  )
}
```

| Block | What it does |
|------|---------------|
| `include` | Inherit configuration from `root.hcl` |
| `locals` | Load values from `root.hcl`, `account.hcl`, `env.hcl` and `region.hcl` |
| `terraform.source` | Points to the Terraform module |
| `before_hook` | Execute before Terraform |
| `after_hook` | Execute after Terraform |
| `extra_arguments` | Automatically pass CLI arguments |
| `dependency` | Read outputs from another module |
| `mock_outputs` | Fake outputs during `plan` |
| `prevent_destroy` | Prevent accidental destroy |
| `inputs` | Pass values to Terraform |
| `merge()` | Merge common tags with environment-specific tags |

> [!NOTE]
> **Real World Use**
>
> A service's `terragrunt.hcl` should only contain configuration. Infrastructure logic stays inside the Terraform module.

> [!IMPORTANT]
> **Interview Tip**
>
> `inputs` is the bridge between Terragrunt configuration and Terraform variables.

---

# 💻 Common Commands

```bash
terragrunt init
terragrunt plan
terragrunt apply
terragrunt destroy
terragrunt output

terragrunt run --all plan
terragrunt run --all apply
terragrunt run --all destroy
```

> [!TIP]
> `run --all` executes commands across all modules while respecting dependencies.

---

# 📝 Quick Revision

- Terraform = Infrastructure
- Terragrunt = Orchestration
- `root.hcl` = Shared configuration
- `include` = Inherit `root.hcl`
- `locals` = Read reusable configuration
- `inputs` = Pass values to Terraform
- `dependency` = Read module outputs
- `mock_outputs` = Fake outputs for planning
- `.terragrunt-cache` = Temporary downloaded module
