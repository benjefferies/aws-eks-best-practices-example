variable "route53_zone_name" {
  description = "The name of the Route53 zone"
  type        = string
}

variable "cluster_dns_zone_name" {
  description = "The name of the cluster DNS zone"
  type        = string
}

variable "cluster_zone_name_servers" {
  description = "The name servers of the cluster DNS zone"
  type        = list(string)
}
