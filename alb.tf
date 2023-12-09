resource "aws_lb" "app_lb" {
  name               = "2191420-cohort-demo-alb"
  load_balancer_type = "application"
  subnets            = var.ecs_public_subnet_ids
  idle_timeout       = 60
  security_groups    = [var.aws_security_group_application_elb_sg_id]
}

locals {
  target_groups = [
    "blue",
    "green"
  ]
  tags = var.resource_tags
}

resource "aws_lb_target_group" "tg" {
  count = length(local.target_groups)

  name        = "2191420-tg-${element(local.target_groups, count.index)}"
  //port        = 443
  port = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200"
    path    = var.health_check_path
  }
  tags = var.resource_tags
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
  tags = var.resource_tags
}

resource "aws_alb_listener" "listener_8080" {
  load_balancer_arn = aws_lb.app_lb.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[1].arn
  }
  tags = var.resource_tags
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


///////////////////////////////////////////////////////////////////////////////////////////////////////



resource "aws_lb" "app_lb_internal" {
  name               = "2191420-cohort-demo-alb-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.ecs_private_subnet_ids
  idle_timeout       = 60
  security_groups    = [var.aws_security_group_application_elb_internal_sg_id]
  tags = var.resource_tags
}

resource "aws_lb_target_group" "tg_internal" {
  count = length(local.target_groups)

  name        = "2191420-internal-tg-${element(local.target_groups, count.index)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200"
    path    = var.health_check_path
  }
  tags = var.resource_tags
}

resource "aws_alb_listener" "internal_listener_80" {
  load_balancer_arn = aws_lb.app_lb_internal.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_internal[0].arn
  }
  depends_on = [aws_lb_target_group.tg_internal]
  tags = var.resource_tags
}

resource "aws_alb_listener" "internal_listener_8080" {
  load_balancer_arn = aws_lb.app_lb_internal.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_internal[1].arn
  }
  tags = var.resource_tags
}