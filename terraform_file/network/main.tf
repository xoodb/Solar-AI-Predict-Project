/* ---vpc--- */
/* VPC generate */
resource "aws_vpc" "saps_vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.env}-${var.project}-${var.vpc_name}" }
}

/* default Route table rename */
resource "aws_default_route_table" "vpc_rt" {
  default_route_table_id = aws_vpc.saps_vpc.default_route_table_id
  tags                   = { Name = "${var.env}-${var.project}-${var.vpc_name}-default" }
}

/* default Security Group rename */
resource "aws_default_security_group" "vpc_sg" {
  vpc_id = aws_vpc.saps_vpc.id
  tags   = { Name = "${var.env}-${var.project}-${var.vpc_name}-default" }
}

/* Creating a VPC Connection IGW */
resource "aws_internet_gateway" "saps_vpc_igw" {
  vpc_id = aws_vpc.saps_vpc.id
  tags   = { Name = "${var.env}-${var.project}-${var.vpc_name}-igw" }
}

/* ---public subnet--- */
/* Define public subnet */
resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.saps_vpc.id
  cidr_block              = each.value["cidr"]
  availability_zone       = each.value["zone"]
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.env}-${var.project}-${var.vpc_name}-${each.key}",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "kubernetes.io/role/elb"                    = "1"
  }
}

/* Define public subnet route table */
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.saps_vpc.id
  tags = {
    Name = "${var.env}-${var.project}-${var.vpc_name}-public-rt"
  }
}

/* Forward to IGW */
resource "aws_route" "public_worldwide" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.saps_vpc_igw.id
}

/* Connect public subnet to route table */
resource "aws_route_table_association" "public_rt_association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

/* ---NAT GW--- */
/* NAT EIP */
resource "aws_eip" "nat_eip" {
  for_each = var.public_subnets
  domain   = "vpc"
  tags = {
    Name = "${var.env}-${var.project}-nat-${each.value["desc"]}-eip"
  }
}

/* private subnet NAT */
resource "aws_nat_gateway" "nat_gw" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = {
    Name = "${var.env}-${var.project}-nat-${each.value["desc"]}-natgw"
  }
}

/* Define private subnet */
resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.saps_vpc.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["zone"]
  tags = {
    Name = "${var.env}-${var.project}-${var.vpc_name}-${each.key}",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

/* Define private subnet route table */
resource "aws_route_table" "private_rt" {
  for_each = var.public_subnets
  vpc_id   = aws_vpc.saps_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[each.key].id
  }

  tags = {
    Name = "${var.env}-${var.project}-${var.vpc_name}-private-${each.value["desc"]}_rt"
  }
}

/* Connect private subnet to route table */
resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private_rt[each.value["pri_rt"]].id
}
/* ---private subnet--- */