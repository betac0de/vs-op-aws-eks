# -----------------------------------------------------------------------------
# PROVIDER CONFIGURATION
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
}

# -----------------------------------------------------------------------------
# NETWORKING RESOURCES
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# -----------------------------------------------------------------------------
# SUBNETS (DYNAMICALLY CREATED PER AVAILABILITY ZONE)
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  # Creates one public subnet in each availability zone listed in var.availability_zones
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  map_public_ip_on_launch = true

  # cidrsubnet calculates a unique CIDR range for each subnet.
  # We use index() to get a unique number for each AZ.
  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, each.key))

  tags = {
    "Name"                                             = "${var.env}-public-${each.key}"
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private" {
  # Creates one private subnet in each availability zone
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key

  # The '4' here offsets the private subnets from the public ones to avoid IP overlap.
  # This assumes a maximum of 4 public subnets. Adjust if needed.
  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, each.key) + 4)

  tags = {
    "Name"                                             = "${var.env}-private-${each.key}"
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

# -----------------------------------------------------------------------------
# NAT GATEWAY (ONE PER PUBLIC SUBNET FOR HIGH AVAILABILITY)
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  # Creates one Elastic IP for each public subnet
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "${var.env}-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  # Creates one NAT Gateway for each public subnet, using the EIPs from above
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.env}-nat-gw-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}

