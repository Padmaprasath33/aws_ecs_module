resource "aws_lb" "app_lb" {
  name               = "cohort-demo-alb"
  load_balancer_type = "application"
  subnets            = var.ecs_subnet_ids
  idle_timeout       = 60
  security_groups    = [var.aws_security_group_application_elb_sg_id]
}

locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_lb_target_group" "tg" {
  count = length(local.target_groups)

  name        = "cohort-demo-tg-${element(local.target_groups, count.index)}"
  port        = 443
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302,404"
    path    = "/"
  }
}

resource "aws_alb_listener" "listener_80" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  /*default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }*/
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
  depends_on = [aws_lb_target_group.tg]
}

resource "aws_alb_listener" "listener_8080" {
  load_balancer_arn = aws_lb.app_lb.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[1].arn
  }
}

/*resource "aws_alb_listener" "listener_443" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  //certificate_arn   = XXXX
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
  depends_on = [aws_lb_target_group.tg]

  lifecycle {
    ignore_changes = [default_action]
  }
}
*/