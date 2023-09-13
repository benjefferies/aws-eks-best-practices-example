output "my-project-owner-email-dev" {
  value = aws_organizations_account.my_project_dev.email
}

output "my-project-owner-email-prod" {
  value = aws_organizations_account.my_project_prod.email
}
