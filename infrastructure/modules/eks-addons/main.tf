data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# Cluster
################################################################################

module "eks_blueprints_addons" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name                   = var.cluster_name
  cluster_endpoint               = var.cluster_endpoint
  cluster_version                = var.cluster_version
  oidc_provider_arn              = var.oidc_provider_arn
  external_dns_route53_zone_arns = [var.route53_zone_arn]

  # ArgoCD
  argocd = {
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
    set = [
      {
        name  = "server.service.type"
        value = "NodePort"
      },
      {
        name  = "server.ingress.enabled"
        value = true
      },
      {
        name  = "server.ingress.hostname"
        value = "argocd.my-project-dev.echosoft.uk"
      },
      {
        name  = "server.ingress.hosts[0]"
        value = "argocd.my-project-dev.echosoft.uk"
      },
      {
        name  = "server.ingress.tls[0].hosts[0]"
        value = "argocd.my-project-dev.echosoft.uk"
      },
      {
        name  = "server.ingress.tls[0].secretName"
        value = "argocd.my-project-dev.echosoft.uk-tls"
      },
      {
        name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
        value = "alb"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
        value = "internet-facing"
      },
      {
        name  = "server.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
        value = "argocd.my-project-dev.echosoft.uk"
      },
    ]

    values = [
      <<EOT
    configs:
      params:
        server.insecure: "true"
    server:
      ingress:
        annotations:
          alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}, {"HTTP":80}]'
          alb.ingress.kubernetes.io/certificate-arn: '${var.cluster_ssl_certificate_arn}'
    EOT
    ]
  }

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  aws_for_fluentbit = {
    set = [
      {
        name  = "cloudWatchLogs.autoCreateGroup"
        value = "true"
      }
    ]
  }

  # Add-ons
  enable_aws_load_balancer_controller = true
  # enable_cluster_proportional_autoscaler = true Enable to scale replicas based on the number of nodes in a cluster
  enable_karpenter             = true
  enable_kube_prometheus_stack = true
  enable_metrics_server        = true
  enable_external_dns          = true
  enable_argocd                = true
  enable_argo_rollouts         = true
  enable_aws_for_fluentbit     = true
}

#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length  = 16
  special = false
}

# Argo requires the password to be bcrypt, we use custom provider of bcrypt,
# as the default bcrypt function generates diff for each terraform plan
resource "bcrypt_hash" "argo" {
  cleartext = random_password.argocd.result
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name                    = "argocd"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}
