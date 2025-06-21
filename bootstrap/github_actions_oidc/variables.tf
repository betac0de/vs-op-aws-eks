# bootstrap/github_actions_oidc/variables.tf

variable "aws_region" {
  description = "The AWS region where the OIDC provider and role will be created."
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "Your GitHub organization name. Case-sensitive."
  type        = string
  # Example: "my-awesome-org"
}

variable "github_repo" {
  description = "The name of the GitHub repository that will assume this role. Case-sensitive."
  type        = string
  # Example: "my-cool-app"
}

variable "deployment_role_name" {
  description = "A unique name for the IAM deployment role."
  type        = string
  default     = "GitHubActions-Deployment-Role"
}

variable "tags" {
  description = "A map of tags to assign to the created resources."
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "GitHub-OIDC-Bootstrap"
    Description = "IAM Role for GitHub Actions CI/CD"
  }
}