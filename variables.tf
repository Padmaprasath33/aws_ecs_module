variable "cohort_demo_ecs_cluster_name" {
  description = "ECS cluster name"
  //default     = ""
}

variable "ecs_fargate_cpu" {
  description = "ECS fargate cpu"
  //default     = ""
}

variable "ecs_fargate_memory" {
  description = "ECS fargate memory"
  //default     = ""
}

variable "aws_account_id" {
  description = "AWS account ID"
  //default     = ""
}

variable "region" {
  description = "AWS region"
  //default     = ""
}

variable "ecr_repo_name" {
  description = "AWS ecr_repo_name"
  //default     = ""
}

variable "image_tag" {
  description = "AWS ECR image tag"
  //default     = ""
}

variable "container_port" {
  description = "ECS container_port"
  //default     = ""
}

variable "efs_volume_name" {
  description = "AWS EFS volume name"
  //default     = ""
}

variable "aws_efs_file_system_id" {
  description = "AWS EFS file system id"
  //default     = ""
}

/*variable "aws_efs_access_point_id" {
  description = "AWS EFS access point id"
  //default     = ""
}
*/

variable "ecs_tasks_sg" {
  description = "AWS ECS tasks security groups"
  //default     = ""
}

variable "alb_sg" {
  description = "AWS ECS ALB security groups"
  //default     = ""
}

variable "ecs_subnet_ids" {
  description = "ECS subnet ids"
  type    = list(string)
  default     = ["", ""] 
}

variable "vpc_id" {
  description = "VPC main id"
  //default     = ""
}

variable "aws_security_group_application_elb_sg_id" {
  description = "aws security group for application load balancer id"
  //default     = ""
}

variable "lb_target_group_name" {
  type    = string
  default = "tg"
}