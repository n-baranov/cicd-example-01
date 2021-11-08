data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "current" {}

data "aws_subnet_ids" "id" {
  vpc_id = aws_vpc.main.id

  depends_on = [
    aws_subnet.subnets,
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.aws_eks.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.aws_eks.name
}

data "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
  }

  depends_on = [
    kubernetes_config_map.aws_auth
  ]
}
