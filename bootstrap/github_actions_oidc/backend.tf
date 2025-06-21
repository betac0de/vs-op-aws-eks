terraform {
  backend "s3" {
    bucket         = "972842348930-test"
    key            = "terraform/vs-op-aws-eks/oidc.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-cluster-lock-table"
  }
}