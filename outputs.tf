output "name" {
  value = var.use_domain ? aws_route53_record.server_record[0].fqdn : aws_instance.EC2_server.public_ip
}
