resource "aws_lb" "bpdts_tech_test" {
  name               = "bpdts-tech-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bpdts_tech_test_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_security_group" "bpdts_tech_test_lb" {
  name   = "bpdts-tech-test-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_alb_target_group" "bpdts_tech_test" {
  name        = "bpdts-tech-test"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_alb_listener" "bpdts_tech_test" {
  load_balancer_arn = aws_lb.bpdts_tech_test.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.bpdts_tech_test.id
    type             = "forward"
  }
}

resource "aws_security_group_rule" "bpdts_tech_test_lb_ingress_from_anywhere" {
  security_group_id = aws_security_group.bpdts_tech_test_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bpdts_tech_test_lb_to_ecs_task" {
  security_group_id        = aws_security_group.bpdts_tech_test_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5000
  to_port                  = 5000
  source_security_group_id = aws_security_group.bpdts_tech_test_task.id
}