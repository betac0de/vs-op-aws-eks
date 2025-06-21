output "github_actions_deployment_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions. This is needed for the workflow file."
  value       = aws_iam_role.github_actions_deployment_role.arn
}