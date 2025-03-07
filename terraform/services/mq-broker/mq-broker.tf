resource "aws_security_group" "mq_sg" {
  name        = "mq-security-group"
  description = "Security group for Amazon MQ"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15671
    to_port     = 15671
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-security-group"
  }
}

resource "aws_mq_broker" "rabbitmq_broker" {
  broker_name         = var.name
  engine_type         = "RabbitMQ"
  engine_version      = var.rabbit_mq_version
  host_instance_type  = var.instance_type
  deployment_mode     = var.deployment_mode
  subnet_ids          = var.subnet_ids
  publicly_accessible = false
  auto_minor_version_upgrade = true
  security_groups     = [aws_security_group.mq_sg.id]

  logs {
    general = true
  }
  configuration {
    id       = aws_mq_configuration.rabbitmq_broker_config.id
    revision = aws_mq_configuration.rabbitmq_broker_config.latest_revision
  }
  user {
    username = var.username
    password = var.password
  }

  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  apply_immediately = true
}
resource "aws_mq_configuration" "rabbitmq_broker_config" {
  description    = "RabbitMQ config"
  name           = "${var.name}-config"
  engine_type    = "RabbitMQ"
  engine_version = var.rabbit_mq_version
  data           = <<DATA
# Default RabbitMQ delivery acknowledgement timeout is 30 minutes in milliseconds
consumer_timeout = 1800000
DATA
}
