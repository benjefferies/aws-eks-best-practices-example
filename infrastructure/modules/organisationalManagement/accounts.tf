locals {
  my_project_email_owner_dev  = replace(var.my_project_email_owner, "@", "+dev@")
  my_project_email_owner_prod = replace(var.my_project_email_owner, "@", "+prod@")
}

resource "aws_organizations_account" "my_project_dev" {
  name      = "my-project-dev"
  email     = local.my_project_email_owner_dev
  parent_id = aws_organizations_organizational_unit.my_project.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "my_project_prod" {
  name      = "my-project-prod"
  email     = local.my_project_email_owner_prod
  parent_id = aws_organizations_organizational_unit.my_project.id

  lifecycle {
    prevent_destroy = true
  }
}
