resource "aws_codedeploy_app" "cohort_demo_ui_app" {
  compute_platform = "ECS"
  name             = "2191420-cohort-demo-ui-app-deploy"
  tags = var.resource_tags
}

resource "aws_codedeploy_deployment_group" "cohort_demo_ui_app_deployment_group" {
  app_name               = aws_codedeploy_app.cohort_demo_ui_app.name
  deployment_group_name  = "2191420-cohort-demo-ui-app-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cohort_demo_ecs_cluster.name
    service_name = aws_ecs_service.cohort-demo-ui-service.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        //listener_arns = [aws_alb_listener.listener_443.arn]
        listener_arns = [aws_alb_listener.listener_80.arn]
      }

      /*test_traffic_route {
        listener_arns = [aws_alb_listener.listener_8080.arn]
      }*/
      

      target_group {
        name = aws_lb_target_group.tg[0].name
      }

      target_group {
        name = aws_lb_target_group.tg[1].name
      }
    }
  }
  tags = var.resource_tags
}

/////////////////////////////////////////////////////////


resource "aws_codedeploy_app" "cohort_demo_backend_app" {
  compute_platform = "ECS"
  name             = "2191420-cohort-demo-backend-app-deploy"
  tags = var.resource_tags
}

resource "aws_codedeploy_deployment_group" "cohort_demo_backend_app_deployment_group" {
  app_name               = aws_codedeploy_app.cohort_demo_backend_app.name
  deployment_group_name  = "2191420-cohort-demo-backend-app-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cohort_demo_ecs_cluster.name
    service_name = aws_ecs_service.cohort-demo-backend-service.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        //listener_arns = [aws_alb_listener.listener_443.arn]
        listener_arns = [aws_alb_listener.internal_listener_80.arn]
      }

      /*test_traffic_route {
        listener_arns = [aws_alb_listener.internal_listener_8080.arn]
      }*/

      target_group {
        name = aws_lb_target_group.tg_internal[0].name
      }

      target_group {
        name = aws_lb_target_group.tg_internal[1].name
      }
    }
  }
  tags = var.resource_tags
}
