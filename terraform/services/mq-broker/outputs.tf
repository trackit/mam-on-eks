output "rabbitmq_broker_ip" {
  value = regex("^amqps://([^:]+):.*$", aws_mq_broker.rabbitmq_broker.instances.0.endpoints.0)[0]
}
