dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "my-project-dev"
    cluster_endpoint = "https://example.com"
    cluster_version = "1.27"
    oidc_provider = "oidc.eks.eu-west-1.amazonaws.com/id/12345678901234567890123456789012"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/12345678901234567890123456789012"
  }

}

dependency "cluster-dns" {
  config_path = "../cluster-dns"

  mock_outputs = {
    zone_id = "Z1234567890"
    zone_name = "my-project-dev.example.com"
    zone_name_servers = ["ns-123.awsdns-12.org", "ns-456.awsdns-34.co.uk", "ns-789.awsdns-56.com", "ns-012.awsdns-78.net"]
    zone_arn = "arn:aws:route53:::hostedzone/Z1234567890"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "eu-west-1"
  profile = "my-project-dev"
}

provider "kubernetes" {
  host = "${dependency.eks.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--profile", "my-project-dev", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
  }
}

provider "helm" {
  kubernetes {
    host = "${dependency.eks.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--profile", "my-project-dev", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = "${dependency.eks.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--profile", "my-project-dev", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
  }
}

provider "bcrypt" {}
EOF
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//eks-addons"
}

inputs = {
  region = "eu-west-1"
  cluster_name = dependency.eks.outputs.cluster_name
  cluster_endpoint = dependency.eks.outputs.cluster_endpoint
  cluster_version = dependency.eks.outputs.cluster_version
  cluster_domain = dependency.cluster-dns.outputs.zone_name
  oidc_provider = dependency.eks.outputs.oidc_provider
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  route53_zone_arn = dependency.cluster-dns.outputs.zone_arn
  cluster_ssl_certificate_arn = dependency.cluster-dns.outputs.cluster_ssl_certificate_arn
}
