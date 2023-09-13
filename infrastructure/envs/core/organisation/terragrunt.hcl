# Reference parent terragrunt configuration
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//modules/organisation"
}

inputs = {
  my_project_email_owner = "benjefferies@echosoft.uk"
  dev_user_email_list = [{
    email = "benjefferies+my-project-dev@echosoft.uk"
    first_name = "Ben"
    last_name = "Jefferies"
  }]
}