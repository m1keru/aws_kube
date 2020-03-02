data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "kube" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = "true"
}

resource "aws_eip" "master" {
  count = "1"
  vpc   = true
  instance = aws_instance.master[count.index].id
  depends_on = [aws_internet_gateway.gw,]
}



resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.master[0].id
  allocation_id = aws_eip.master[0].id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.kube.id
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kube.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}


resource "aws_route_table_association" "kube" {
  count = length(aws_subnet.private)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.kube.id
  count             = length(data.aws_availability_zones.az.names)
  cidr_block        = var.private_subnet_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
}
