output "zone_id" {
  value = aws_route53_zone.my_project_dev_zone.zone_id
}

output "zone_name" {
  value = aws_route53_zone.my_project_dev_zone.name
}

output "zone_name_servers" {
  value = aws_route53_zone.my_project_dev_zone.name_servers
}

output "zone_arn" {
  value = aws_route53_zone.my_project_dev_zone.arn
}

output "cluster_ssl_certificate_arn" {
  value = aws_acm_certificate.wildcard_ssl_certificate.arn
}
