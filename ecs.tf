resource "aws_ecs_cluster" "cohort_demo_ecs_cluster" {
  name = var.cohort_demo_ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.cohort_demo_kms.arn
      logging    = "DEFAULT"

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
  name = var.cohort_demo_ecs_log_group
}


