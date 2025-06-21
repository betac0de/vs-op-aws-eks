terraform {
  backend "s3" {
    bucket         = "972842348930-test"
    key            = "terraform/vs-op-aws-eks/aws-eks.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-cluster-lock-table"
  }
}