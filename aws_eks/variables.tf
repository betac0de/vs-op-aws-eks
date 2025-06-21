variable "env" {
  description = "The deployment environment name (e.g., staging, prod)."
  type        = string
  default     = "staging"
}

variable "region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "eks_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones to deploy subnets into."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}