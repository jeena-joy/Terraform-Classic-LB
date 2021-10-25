output "lb_address" {
  value = aws_elb.classic.public_dns
}

output "lb_dns-name" {
  value = aws_elb.classic.dns_name 
}

output "elb-arn"  {
  value = aws_elb.classic.arn
}
