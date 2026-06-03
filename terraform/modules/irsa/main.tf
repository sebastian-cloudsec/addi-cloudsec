# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.cluster_name}-${var.namespace}-${var.service_account_name}"
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = merge(var.tags, {
    "addi:component"       = "irsa"
    "addi:cluster"         = var.cluster_name
    "addi:namespace"       = var.namespace
    "addi:service-account" = var.service_account_name
  })
}

data "aws_iam_policy_document" "permissions" {
  stateme
