output "cluster_id" {
  value = aws_eks_cluster.terraform.id
}

output "node_group_id" {
  value = aws_eks_node_group.terraform.id
}

output "vpc_id" {
  value = aws_vpc.terraform_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.terraform_subnet[*].id
}
