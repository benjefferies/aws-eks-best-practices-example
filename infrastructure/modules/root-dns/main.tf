data "aws_route53_zone" "my_project_dev_zone" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "delegation_record" {
  zone_id = data.aws_route53_zone.my_project_dev_zone.zone_id
  name    = var.cluster_dns_zone_name
  type    = "NS"
  ttl     = "300"

  records = var.cluster_zone_name_servers
}
