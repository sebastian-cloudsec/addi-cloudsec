# ---------------------------------------------------------------------------
# Example: payments service — least-privilege IRSA binding
#
# This file shows how a team onboards a new microservice onto the
# IRSA pattern. No IAM console access needed. Security is declared
# alongside the application's infrastructure code.
# ---------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.addi.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.addi.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.addi.token
}

data "aws_eks_cluster" "addi" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "addi" {
  name = var.cluster_name
}

# ---------------------------------------------------------------------------
# Payments service — access only to its own DynamoDB table and S3 bucket
# ---------------------------------------------------------------------------

module "payments_irsa" {
  source = "../modules/irsa"

  cluster_name         = var.cluster_name
  service_account_name = "payments-svc"
  namespace            = "payments"

  resource_arns = [
    "arn:aws:dynamodb:us-east-1:123456789012:table/addi-payments-prod",
    "arn:aws:s3:::addi-payments-receipts-prod",
    "arn:aws:s3:::addi-payments-receipts-prod/*"
  ]

  allowed_actions = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:Query",
    "s3:GetObject",
    "s3:PutObject"
  ]

  tags = {
    environment = "prod"
    team        = "payments"
  }
}

# ---------------------------------------------------------------------------
# Auth service — access only to its JWT secret in Secrets Manager
# ---------------------------------------------------------------------------

module "auth_irsa" {
  source = "../modules/irsa"

  cluster_name         = var.cluster_name
  service_account_name = "auth-svc"
  namespace            = "auth"

  resource_arns = [
    "arn:aws:secretsmanager:us-east-1:123456789012:secret/addi-auth-jwt-key-*"
  ]

  allowed_actions = [
    "secretsmanager:GetSecretValue",
    "secretsmanager:DescribeSecret"
  ]

  tags = {
    environment = "prod"
    team        = "identity"
  }
}

variable "aws_region" {
  description = "AWS region where the EKS cluster lives."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the Addi EKS cluster."
  type        = string
  default     = "addi-prod"
}

output "payments_role_arn" {
  value = module.payments_irsa.role_arn
}

output "auth_role_arn" {
  value = module.auth_irsa.role_arn
}
