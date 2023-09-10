output "argo_server_password" {
  value     = random_password.argocd.result
  sensitive = true
}

output "argo_server_password_bcrypt" {
  value     = bcrypt_hash.argo.id
  sensitive = false
}
