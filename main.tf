#create ECR rep
resource "aws_ecr_repository" "repository" {
  for_each = toset(var.repository_list)
  name     = each.key
}

#build docker image and push to ECR
resource "docker_registry_image" "docker_image" {
  for_each = toset(var.repository_list)
  name     = "${aws_ecr_repository.repository[each.key].repository_url}:latest"

  build {
    context    = "../application_folder"
    dockerfile = "${each.key}.Dockerfile"
  }
}

#create VPC with subnets
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.vpc_name}-VPC"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-IGW"
  }

  depends_on = [
    aws_vpc.main,
  ]
}

#create subnets
resource "aws_subnet" "subnets" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets_cidr["${count.index}"]
  availability_zone       = data.aws_availability_zones.available.names["${count.index}"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index + 1}_${var.vpc_name}-VPC"
  }

  depends_on = [
    aws_vpc.main,
  ]
}



#Create routing table with IG routing
/*
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-PRT"
  }
}
*/

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}


#Adding Security Group rules
resource "aws_security_group_rule" "default" {
  security_group_id = aws_eks_cluster.aws_eks.vpc_config.0.cluster_security_group_id
  count             = length(var.ingress_ports)
  type              = "ingress"
  from_port         = var.ingress_ports["${count.index}"]
  to_port           = var.ingress_ports["${count.index}"]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [
    aws_eks_cluster.aws_eks,
  ]
}

/*
#create iam role for cluster
resource "aws_iam_role" "eks_cluster" {
  name               = "eks-cluster"
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

#add policies to the role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name

  depends_on = [
    aws_iam_role.eks_cluster,
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name

  depends_on = [
    aws_iam_role.eks_cluster,
  ]
}

resource "aws_iam_role_policy" "eks-AccessKubernetesApi" {
  name = "eks-AccessKubernetesApi"
  role = aws_iam_role.eks_cluster.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ],
        "Resource" : "*"
      }
    ]
  })

  depends_on = [
    aws_iam_role.eks_cluster,
  ]
}


#create iam role for nodes
resource "aws_iam_role" "eks_nodes" {
  name               = "eks-node-group"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#add policies to the role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name

  depends_on = [
    aws_iam_role.eks_nodes,
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name

  depends_on = [
    aws_iam_role.eks_nodes,
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name

  depends_on = [
    aws_iam_role.eks_nodes,
  ]
}
*/

#create EKS cluster
resource "aws_eks_cluster" "aws_eks" {
  name = "eks_cluster_laravel"
  #role_arn = aws_iam_role.eks_cluster.arn
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/myTerraformEKSRole"

  vpc_config {
    subnet_ids = data.aws_subnet_ids.id.ids
  }

  tags = {
    Name = "EKS laravel"
  }

  depends_on = [
    #    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    #    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_subnet.subnets,
  ]
}

#create EKS nodes
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "nodes_laravel"
  #node_role_arn  = aws_iam_role.eks_nodes.arn
  node_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/myTerraformEKSRole"
  subnet_ids     = data.aws_subnet_ids.id.ids
  instance_types = ["t2.medium"]
  tags = {
    Name = "K8s node"
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    #    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    #    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    #    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.aws_eks,
  ]
}

#add Terraform user (this machine) to the configmap
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    /*
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "Terraform"
        # / are replaced by . because label validator fails in this lib
        # https://github.com/kubernetes/apimachinery/blob/1bdd76d09076d4dc0362456e59c8f551f5f24a72/pkg/util/validation/validation.go#L166
        "terraform.io/module" = "terraform-aws-modules.eks.aws"
      },
      var.aws_auth_additional_labels
    )
    */
  }

  data = {
    mapRoles    = yamlencode(var.map_roles)
    mapUsers    = yamlencode(var.map_users)
    mapAccounts = yamlencode(var.map_accounts)
  }

  depends_on = [aws_eks_cluster.aws_eks]
}

/*
resource "kubernetes_cluster_role" "example" {
  metadata {
    name = "eks-console-dashboard-full-access-group"
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "eks-console-dashboard-full-access-group"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "Terraform"
    api_group = "rbac.authorization.k8s.io"
    namespace = "default"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "aws-auth"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
    namespace = "default"
  }
}
*/
