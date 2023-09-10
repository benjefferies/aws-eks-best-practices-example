data "aws_organizations_organization" "this" {}

locals {
  organization_root_id = data.aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "engineering" {
  name      = "engineering"
  parent_id = local.organization_root_id
}

resource "aws_organizations_organizational_unit" "my_project" {
  name      = "my-project"
  parent_id = aws_organizations_organizational_unit.engineering.id
}