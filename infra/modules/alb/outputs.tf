output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "security_group_id" {
  value = aws_security_group.alb.id
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend.arn
}

output "backend_dns_name" {
  value = aws_lb.this.dns_name
}