dependencies {
  paths = ["../../core/organisation"]
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "eu-west-1"
  profile = "my-project-dev"
}
EOF
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//eks"
}

inputs = {
  name = "my-project-dev"
  region = "eu-west-1"
  initial_instance_type = "t3.large"
  initial_min_size = 2
  initial_max_size = 4
  initial_desired_size = 3
}
