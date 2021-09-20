resource "aws_vpc" "eks_network" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "eks-network"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.eks_network.id
  cidr_block = "10.0.0.128/25"

  tags = {
    Name = "eks-network"
  }
}
