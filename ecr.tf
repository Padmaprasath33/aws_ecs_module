resource "aws_ecr_repository" "cohort_demo" {
  name                 = "cohort_demo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_lifecycle_policy" "cohort_demo_policy" {
  repository = aws_ecr_repository.cohort_demo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only last 10 image versions and expire others",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "cohort_demo_crr" {
  replication_configuration {
    rule {
      destination {
        region      = var.cohort_demo_ecr_crr_region
        registry_id = data.aws_caller_identity.current.account_id
      }
      repository_filter {
        filter      = "cohort_demo"
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}