variable "my_project_email_owner" {
  type = string
}

variable "dev_user_email_list" {
  type = list(object({
    email      = string
    first_name = string
    last_name  = string
  }))
}
