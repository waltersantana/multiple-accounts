output "alb" {
  value = aws_alb.main.dns_name
}

# output "name_servers" {
#   value = aws_route53_zone.main.name_servers
# }

# output "private_subnets" {
#   value = data.aws_subnet.private_subnets
# }