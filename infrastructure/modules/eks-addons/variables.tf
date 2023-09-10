variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "oidc_provider" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "route53_zone_arn" {
  type = string
}

variable "cluster_ssl_certificate_arn" {
  type = string
}
