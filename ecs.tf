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
  tags = var.resource_tags
}

resource "aws_kms_key" "cohort_demo_kms" {
  description             = "KMS key for cohort demo"
  deletion_window_in_days = 10
  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "cohort_demo_ecs_log_group" {
  name = "cohort-demo-ecs-log-group"
  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "cohort_demo_ecs_ui_log_group" {
  name = "cohort-demo-ecs-ui-log-group"
  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "cohort_demo_ecs_backend_log_group" {
  name = "cohort-demo-ecs-backend-log-group"
  tags = var.resource_tags
}

/*data "aws_ecr_image" "cohort_demo" {
  repository_name = "cohort_demo"
  most_recent       = true
}
*/

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
   //image       = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
   image = "nginx"
   essential   = true
   /*"mountPoints": [
          {
              "containerPath": "/usr/share/nginx/html",
              "sourceVolume": var.efs_volume_name
          }
      ]*/
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.cohort_demo_ecs_ui_log_group.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
}])

  /*volume {
    name = var.efs_volume_name

    efs_volume_configuration {
      file_system_id          = var.aws_efs_file_system_id
      root_directory          = "/"
      /*transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = var.aws_efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }*/
  tags = var.resource_tags
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
   //image       = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
   image = "nginx"
   essential   = true
   /*"mountPoints": [
          {
              "containerPath": "/usr/share/nginx/html",
              "sourceVolume": var.efs_volume_name
          }
      ]*/
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.cohort_demo_ecs_backend_log_group.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
}])

  /*volume {
    name = var.efs_volume_name

    efs_volume_configuration {
      file_system_id          = var.aws_efs_file_system_id
      root_directory          = "/"
      /*transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = var.aws_efs_access_point_id
        iam             = "ENABLED"
      }
      
    }
  }*/
  tags = var.resource_tags
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
   security_groups  = [var.ecs_tasks_sg]
   subnets          = var.ecs_private_subnet_ids
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
  tags = var.resource_tags
}

resource "aws_ecs_service" "cohort-demo-backend-service" {
 name                               = "cohort-demo-backend-service"
 cluster                            = aws_ecs_cluster.cohort_demo_ecs_cluster.id
 task_definition                    = aws_ecs_task_definition.cohort_demo_backend_task_definition.arn
 desired_count                      = 3
 deployment_minimum_healthy_percent = 100
 deployment_maximum_percent         = 200
 health_check_grace_period_seconds  = 300
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 force_new_deployment = true
 
 network_configuration {
   security_groups  = [var.ecs_backend_tasks_sg]
   subnets          = var.ecs_private_subnet_ids
   assign_public_ip = false
 }

  load_balancer {
   target_group_arn = aws_lb_target_group.tg_internal[0].arn
   container_name   = "cohort_demo_ecs_container"
   container_port   = var.container_port
 }

 deployment_controller {
    type = "CODE_DEPLOY"
  }
 
 lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }
  tags = var.resource_tags
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cohort_demo_ecs_cluster.name}/${aws_ecs_service.cohort-demo-ui-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = var.resource_tags
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