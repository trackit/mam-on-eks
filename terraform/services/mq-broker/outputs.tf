output "rabbitmq_broker_ip" {
  value =   aws_mq_broker.rabbitmq_broker.instances
  # value = aws_mq_broker.rabbitmq_broker.instances.0.ip_address
}
