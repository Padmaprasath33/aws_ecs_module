resource "aws_ecs_cluster" "cohort_demo_ecs_cluster" {
  name = var.cohort_demo_ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.cohort_demo_kms.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cohort_demo_ecs_log_group.name
      }
    }
  }
}

resource "aws_kms_key" "cohort_demo_kms" {
  description             = "KMS key for cohort demo"
  deletion_window_in_days = 10
}

resource "aws_cloudwatch_log_group" "cohort_demo_ecs_log_group" {
  name = "cohort_demo_ecs_log_group_${var.region}"
}

data "aws_ecr_image" "cohort_demo" {
  repository_name = "cohort_demo"
  most_recent       = true
}

resource "aws_ecs_task_definition" "cohort_demo_ui_task_definition" {
  family = "cohort_demo_ui_task_definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_cpu
  memory                   = var.ecs_fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
   name        = "cohort_demo_ecs_container"
   //412699049661.dkr.ecr.us-east-1.amazonaws.com/cohort_demo:5dab2de
   image       = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
   essential   = true
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/cohort_demo_ui_task_definition"
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
}])

  volume {
    name = var.efs_volume_name

    efs_volume_configuration {
      file_system_id          = var.aws_efs_file_system_id
      root_directory          = "/opt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      /*authorization_config {
        access_point_id = var.aws_efs_access_point_id
        iam             = "ENABLED"
      }*/
    }
  }
}

resource "aws_ecs_task_definition" "cohort_demo_backend_task_definition" {
  family = "cohort_demo_backend_task_definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_cpu
  memory                   = var.ecs_fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
   name        = "cohort_demo_ecs_container"
   //412699049661.dkr.ecr.us-east-1.amazonaws.com/cohort_demo:5dab2de
   image       = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
   essential   = true
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/cohort_demo_backend_task_definition"
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
}])

  volume {
    name = var.efs_volume_name

    efs_volume_configuration {
      file_system_id          = var.aws_efs_file_system_id
      root_directory          = "/opt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      /*authorization_config {
        access_point_id = var.aws_efs_access_point_id
        iam             = "ENABLED"
      }*/
    }
  }
}

resource "aws_ecs_service" "cohort-demo-ui-service" {
 name                               = "cohort-demo-ui-service"
 cluster                            = aws_ecs_cluster.cohort_demo_ecs_cluster.id
 task_definition                    = aws_ecs_task_definition.cohort_demo_ui_task_definition.arn
 desired_count                      = 3
 deployment_minimum_healthy_percent = 100
 deployment_maximum_percent         = 200
 health_check_grace_period_seconds  = 300
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 force_new_deployment = true
 
 network_configuration {
   security_groups  = var.ecs_tasks_sg
   subnets          = var.ecs_subnet_ids
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_lb_target_group.tg[0].arn
   container_name   = "cohort_demo_ecs_container"
   container_port   = var.container_port
 }
 deployment_controller {
    type = "CODE_DEPLOY"
  }
 
 lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }
}

/*resource "aws_lb" "cohort_demo_alb" {
  name               = "cohort_demo_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg
  subnets            = var.ecs_subnet_ids
 
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "cohort_demo_alb_tg" {
  name        = "cohort_demo_alb_tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "5"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "5"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.cohort_demo_alb.id
  port              = 80
  protocol          = "HTTP"
 
  //default_action {
   //type = "redirect"
 
   //redirect {
    // port        = 443
    // protocol    = "HTTPS"
    // status_code = "HTTP_301"
   //}
  //}
  

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cohort_demo_alb_tg.arn
  }

}
*/
/*resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.cohort_demo_alb.id
  port              = 443
  protocol          = "HTTPS"
 
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_tls_cert_arn
 
  default_action {
    target_group_arn = aws_alb_target_group.cohort_demo_alb_tg.id
    type             = "forward"
  }
}
*/

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cohort_demo_ecs_cluster.name}/${aws_ecs_service.cohort-demo-ui-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
 
   target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
 
   target_value       = 70
  }
}