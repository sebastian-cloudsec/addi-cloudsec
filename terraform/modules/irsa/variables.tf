variable "cluster_name" {
  description = "Name of the EKS cluster. Used to look up the OIDC provider ARN."
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account to bind to the IAM role."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where the service account lives."
  type        = string
}

variable "resource_arns" {
  description = "List of AWS resource ARNs this service is allowed to access."
  type        = list(string)
}

variable "allowed_actions" {
  description = "List of IAM actions to allow on the specified resource_arns."
  type        = list(string)
  default = [
    "dynamodb:GetItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "s3:GetObject",
    "s3:ListBucket"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
