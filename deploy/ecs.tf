resource "aws_ecs_cluster" "bpdts_tech_test" {
  name               = "bpdts-tech-test"
  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_ecs_service" "bpdts_tech_test" {
  name            = "bpdts-tech-test"
  cluster         = aws_ecs_cluster.bpdts_tech_test.id
  task_definition = aws_ecs_task_definition.bpdts_tech_test.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.bpdts_tech_test_task.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.bpdts_tech_test.id
    container_name   = "bpdts-tech-test"
    container_port   = 5000
  }
}

resource "aws_ecs_task_definition" "bpdts_tech_test" {
  family                   = "bpdts-tech-test"
  container_definitions    = file("${path.module}/templates/task-definition.json")
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

resource "aws_security_group" "bpdts_tech_test_task" {
  name   = "bpdts-tech-test-task"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "bpdts_tech_test_allow_ingress_from_lb" {
  security_group_id        = aws_security_group.bpdts_tech_test_task.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5000
  to_port                  = 5000
  source_security_group_id = aws_security_group.bpdts_tech_test_lb.id
}

resource "aws_security_group_rule" "bpdts_tech_test_allow_egress" {
  security_group_id = aws_security_group.bpdts_tech_test_task.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}
