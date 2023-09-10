remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    profile        = "my-project-dev"
    bucket         = "devops-aws-eks-dev-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devops-aws-eks-dev-terraform-state-lock"
  }
}