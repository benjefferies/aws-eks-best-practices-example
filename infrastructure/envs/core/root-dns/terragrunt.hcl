dependency "cluster-dns" {
  config_path = "../../dev/cluster-dns"

  mock_outputs = {
    route53_zone_name = "Z1234567890"
    cluster_dns_zone_name = "cluster.example.com"
    cluster_zone_name_servers = ["ns-123.awsdns-12.com", "ns-456.awsdns-34.net"]
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//root-dns"
}

inputs = {
  route53_zone_name = "echosoft.uk"
  cluster_dns_zone_name = dependency.cluster-dns.outputs.zone_name
  cluster_zone_name_servers = dependency.cluster-dns.outputs.zone_name_servers
}
