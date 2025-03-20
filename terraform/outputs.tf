output "elasticache_endpoint" {
    description = "value of the primary endpoint"
    value = module.elasticache.primary_endpoint
}

output "elasticsearch_endpoint" {
    description = "value of the endpoint"
    value = module.elasticsearch.elasticsearch_endpoint
}

output "mq_endpoint" {
    description = "value of the endpoint"
    value = module.rabbitmq.rabbitmq_broker_ip
}

output "rds_endpoint" {
    description = "value of the endpoint"
    value = module.database.rds_address
}
