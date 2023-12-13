resource "aws_service_discovery_private_dns_namespace" "cohort_demo_service_discovery_namespace" {
  name        = "2191420-cohort-demo-namespace"
  description = "Cohort private dns namespace for service discovery"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "cohort_demo_service_discovery" {
  name = "2191420-cohort-demo-service-name"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cohort_demo_service_discovery_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}