# api server
resource "aws_instance" "api" {
  count                  = 1
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.small"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public-subnet-a.id
  vpc_security_group_ids = [aws_security_group.api.id]

  associate_public_ip_address = true
  private_ip                  = format("10.0.1.1%d", count.index)

  tags = {
    Name = format("${var.base_name}-api-%02d", count.index + 1)
  }
}

resource "aws_lb" "alb" {
  name               = "${var.base_name}-api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-c.id]
}

resource "aws_alb_target_group" "api" {
  name     = "${var.base_name}-api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod-vpc.id

  health_check {
    interval            = 30
    path                = "/health"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_target_group_attachment" "api" {
  count            = 1
  target_group_arn = aws_alb_target_group.api.arn
  target_id        = aws_instance.api[count.index].id
  port             = 80
}

resource "aws_eip" "api" {
  count    = 1
  instance = aws_instance.api[count.index].id
  vpc = true
}

resource "aws_alb_listener" "api" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.api.arn
  }
}

//resource "aws_alb_listener_rule" "api" {
//  listener_arn = "${aws_alb_listener.api.arn}"
//  priority     = 100
//
//  action {
//    type             = "forward"
//    target_group_arn = "${aws_alb_target_group.api.arn}"
//  }
//
//  condition {
//    field  = "path-pattern"
//    values = ["/target/*"]
//  }
//}
