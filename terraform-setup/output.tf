# output "ubuntu_node_ips" {
#   value = aws_instance.ubuntu_vms.*.public_ip
# }
output "arm_node_ips" {
  value = aws_instance.arm_vms.*.public_ip
}
# output "gpu_node_ips" {
#   value = aws_instance.gpu_vms.*.public_ip
# }

# output "rancher_domain" {
#   value = data.aws_route53_zone.rancher.name
# }
# output "rancher_cluster_ips" {
#   value = [
#     aws_instance.ubuntu_vms.0.public_ip,
#     aws_instance.ubuntu_vms.1.public_ip,
#     aws_instance.ubuntu_vms.2.public_ip,
#   ]
# }
output "all_node_ips" {
  value = concat(
    # aws_instance.ubuntu_vms.*.public_ip,
    aws_instance.arm_vms.*.public_ip,
	# aws_instance.gpu_vms.*.public_ip,
  )
}