/*
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.web_distribution.domain_name
}
*/

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}
