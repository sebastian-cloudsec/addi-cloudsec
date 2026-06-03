output "role_arn" {
  description = "ARN of the IAM role. Use this to verify the binding or reference it from other modules."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role."
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of the least-privilege IAM policy attached to the role."
  value       = aws_iam_policy.this.arn
}

output "service_account_name" {
  description = "Name of the Kubernetes service account created and annotated by this module."
  value       = kubernetes_service_account.this.metadata[0].name
}
