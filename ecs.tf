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
