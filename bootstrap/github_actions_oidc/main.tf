# bootstrap/github_actions_oidc/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# This resource creates the OIDC provider in your AWS account.
# It's a one-time setup per account. If it already exists, Terraform will adopt it.
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # This is the root CA thumbprint for the GitHub OIDC provider.
  # See GitHub's documentation for the latest thumbprint:
  # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# This IAM role will be assumed by your GitHub Actions workflow.
resource "aws_iam_role" "github_actions_deployment_role" {
  name = var.deployment_role_name
  tags = var.tags

  # The trust policy is the most important part. It specifies that only
  # GitHub Actions from your specific repository can assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          # The ARN of the OIDC provider we created above.
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            # This condition restricts the role to a specific GitHub repository.
            # You can use wildcards, e.g., "repo:${var.github_org}/*" to allow all repos in the org.
            # For even tighter security, you can restrict to a specific branch:
            # "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

# --- IMPORTANT ---
# This is a sample policy. You MUST customize the permissions below
# to match the exact requirements of your deployment script.
# Follow the principle of least privilege.
resource "aws_iam_policy" "deployment_policy" {
  name        = "${var.deployment_role_name}-Policy"
  description = "Permissions for the GitHub Actions deployment role."
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::my-app-bucket",
          "arn:aws:s3:::my-app-bucket/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the permissions policy to the deployment role.
resource "aws_iam_role_policy_attachment" "deployment_policy_attachment" {
  role       = aws_iam_role.github_actions_deployment_role.name
  policy_arn = aws_iam_policy.deployment_policy.arn
}