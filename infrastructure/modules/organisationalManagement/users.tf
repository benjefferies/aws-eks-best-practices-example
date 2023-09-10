# Need to enable AWS IAM Identity Store in manually
data "aws_ssoadmin_instances" "default" {
}

locals {
  identity_store_id  = data.aws_ssoadmin_instances.default.identity_store_ids[0]
  identity_store_arn = data.aws_ssoadmin_instances.default.arns[0]
}

resource "aws_identitystore_group" "developers" {
  identity_store_id = local.identity_store_id
  display_name      = "developers"
  description       = "Developers"
}

resource "aws_identitystore_user" "dev_user" {
  count             = length(var.dev_user_email_list)
  identity_store_id = local.identity_store_id
  user_name         = var.dev_user_email_list[count.index].email
  display_name      = "${var.dev_user_email_list[count.index].first_name} ${var.dev_user_email_list[count.index].last_name}"
  emails {
    primary = true
    value   = var.dev_user_email_list[count.index].email
  }
  name {
    given_name  = var.dev_user_email_list[count.index].first_name
    family_name = var.dev_user_email_list[count.index].last_name
  }

}

resource "aws_identitystore_group_membership" "developers" {
  count             = length(var.dev_user_email_list)
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.developers.group_id
  member_id         = aws_identitystore_user.dev_user[count.index].user_id
}

resource "aws_ssoadmin_permission_set" "developers" {
  name         = "AdministratorAccess"
  description  = "Administrator Access"
  instance_arn = local.identity_store_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "developers" {
  instance_arn       = local.identity_store_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.developers.arn
}

resource "aws_ssoadmin_account_assignment" "my-project-dev" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.developers.arn

  principal_id   = aws_identitystore_group.developers.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.my_project_dev.id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "my-project-prod" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.developers.arn

  principal_id   = aws_identitystore_group.developers.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.my_project_prod.id
  target_type = "AWS_ACCOUNT"
}
