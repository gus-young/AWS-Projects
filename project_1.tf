//VPCs
//Establish vpc_1
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.1.0/24"

  tags = {
    Name  = "vpc_1"
  }
}
//Internet Gateway for vpc_1
resource "aws_internet_gateway" "vpc_1_gtw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name  = "vpc_1_gtw"
  }
}
//Subnet for vpc_1
resource "aws_subnet" "vpc_1_sub" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name  = "vpc_1_sub"
  }
}
//Routing Table for vpc_1
resource "aws_route_table" "vpc_1_rte" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_1_gtw.id
  }
  route {
    cidr_block = "10.0.2.0/24"
    gateway_id = aws_vpc_peering_connection.vpc_1_2.id
  }

  tags = {
    Name  = "vpc_1_rte"
  }
}
//Security Group for vpc_1
resource "aws_security_group" "vpc_1_sec" {
  name        = "vpc_1_sec"
  description = "Allow inbound SSH and ICMP traffic"
  vpc_id = aws_vpc.vpc_1.id 
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
//Route Table Association for vpc_1
resource "aws_main_route_table_association" "vpc_1" {
  vpc_id      = aws_vpc.vpc_1.id
  route_table_id = aws_route_table.vpc_1_rte.id
}

//Establish vpc_2
resource "aws_vpc" "vpc_2" {
  cidr_block = "10.0.2.0/24"

  tags = {
    Name  = "vpc_2"
  }
}
//Internet Gateway for vpc_2
resource "aws_internet_gateway" "vpc_2_gtw" {
  vpc_id = aws_vpc.vpc_2.id

  tags = {
    Name  = "vpc_2_gtw"
  }
}
//Subnet for vpc_2
resource "aws_subnet" "vpc_2_sub" {
  vpc_id            = aws_vpc.vpc_2.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name  = "vpc_2_sub"
  }
}
//Routing Table for vpc_2
resource "aws_route_table" "vpc_2_rte" {
  vpc_id = aws_vpc.vpc_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_2_gtw.id
  }
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_vpc_peering_connection.vpc_1_2.id
  }

  tags = {
    Name  = "vpc_2_rte"
  }
}
//Security Group for vpc_2
resource "aws_security_group" "vpc_2_sec" {
  name        = "vpc_2_sec"
  description = "Allow inbound SSH and ICMP traffic"
  vpc_id = aws_vpc.vpc_2.id 
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
//Route Table Association for vpc_2
resource "aws_main_route_table_association" "vpc_2" {
  vpc_id      = aws_vpc.vpc_2.id
  route_table_id = aws_route_table.vpc_2_rte.id
}

//Shared Resources
//Peering Connection
resource "aws_vpc_peering_connection" "vpc_1_2" {
  peer_vpc_id   = "${aws_vpc.vpc_1.id}"
  vpc_id        = "${aws_vpc.vpc_2.id}"
  auto_accept   = true

  tags = {
    Name = "VPC Peering between vpc_1 and vpc_2"
  }
}
//SSH Key Pair
resource "aws_key_pair" "ssh_key_test" {
  key_name   = "ssh_key_test"
  public_key = "*"

//EC2 Instances

//EC2 Instance in vpc_1
resource "aws_instance" "vpc_1_ec2" {
  ami           = "ami-0eb070c40e6a142a3"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.vpc_1_sub.id
  vpc_security_group_ids = [aws_security_group.vpc_1_sec.id]
  key_name = "${aws_key_pair.ssh_key_test.id}"
  associate_public_ip_address = true
  private_ip = "10.0.1.10"

  tags = {
    Name = "vpc_1_ec2"
  }
}
//EC2 Instances in vpc_2
resource "aws_instance" "vpc_2_ec2" {
  ami           = "ami-0eb070c40e6a142a3"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.vpc_2_sub.id
  vpc_security_group_ids = [aws_security_group.vpc_2_sec.id]
  key_name = "${aws_key_pair.ssh_key_test.id}"
  associate_public_ip_address = true
  private_ip = "10.0.2.10"

  tags = {
    Name = "vpc_2_ec2"
  }
}
