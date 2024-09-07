output "cluster_id" {
  value = aws_eks_cluster.regtech.id
}

output "node_group_id" {
  value = aws_eks_node_group.regtech.id
}

output "vpc_id" {
  value = aws_vpc.regtech_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.regtech_subnet[*].id
}