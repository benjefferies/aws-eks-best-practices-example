resource "aws_route53_zone" "my_project_dev_zone" {
  name = var.cluster_dns_zone_name
}
resource "aws_acm_certificate" "wildcard_ssl_certificate" {
  domain_name       = "*.my-project-dev.echosoft.uk"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  domain_to_validate = tolist(aws_acm_certificate.wildcard_ssl_certificate.domain_validation_options)[0]
}

resource "aws_route53_record" "validation_record" {
  name    = local.domain_to_validate.resource_record_name
  type    = local.domain_to_validate.resource_record_type
  zone_id = aws_route53_zone.my_project_dev_zone.zone_id
  records = [local.domain_to_validate.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_ssl_certificate_validation" {
  certificate_arn         = aws_acm_certificate.wildcard_ssl_certificate.arn
  validation_record_fqdns = [aws_route53_record.validation_record.fqdn]
}
