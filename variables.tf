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