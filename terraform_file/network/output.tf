output "vpc_id" {
  value = aws_vpc.saps_vpc.id
}
output "public_subnets" {
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}
output "private_subnets" {
  value = {
    for key, subnet in aws_subnet.private : key => subnet.id
  }
}
output "vpc_igw_id" {
  value = aws_internet_gateway.saps_vpc_igw.id
}