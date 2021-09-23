resource "aws_eks_cluster" "sample" {
  name     = "sample-cluster"
  role_arn = aws_iam_role.cluster_sample.arn

  vpc_config {
    subnet_ids = [aws_subnet.main.id]
  }

  version = 1.21

  tags = {
    Name = "sample"
  }

  depends_on = [
    aws_iam_role_policy_attachment.sample-AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "sample" {
  cluster_name    = aws_eks_cluster.sample.name
  node_group_name = "sample"
  node_role_arn   = aws_iam_role.node_group_sample.arn
  subnet_ids      = aws_subnet.main[*].id

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  capacity_type = "SPOT"

  instance_types = ["t3a.medium"]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "sample"
  }

  depends_on = [
    aws_iam_role_policy_attachment.sample-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.sample-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.sample-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "cluster_sample" {
  name = "eks-cluster-sample"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sample-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_sample.name
}

resource "aws_iam_role" "node_group_sample" {
  name = "eks-node-group-sample"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "sample-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_sample.name
}

resource "aws_iam_role_policy_attachment" "sample-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_sample.name
}

resource "aws_iam_role_policy_attachment" "sample-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_sample.name
}
