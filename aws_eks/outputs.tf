output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "A list of the NAT Gateway IDs."
  value       = [for n in aws_nat_gateway.nat : n.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}