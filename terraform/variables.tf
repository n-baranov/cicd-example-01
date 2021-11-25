variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "repository_list" {
  type    = list(any)
  default = ["backend"]
}

variable "vpc_name" {
  default = "Dev"
}
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "subnets_num" {
  default = 3
}

variable "subnets_cidr" {
  type    = list(any)
  default = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
}

variable "ingress_ports" {
  type    = list(any)
  default = ["22", "80", "443", "8080", "8888"]
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = ["855659683173"]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::855659683173:role/myTerraformEKSRole"
      username = "myTerraformEKSRole"
      groups   = ["system:masters"]
    }
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      userarn  = "arn:aws:iam::855659683173:user/Terraform"
      username = "Terraform"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::855659683173:root"
      username = "Root"
      groups   = ["system:masters"]
    }
  ]
}
