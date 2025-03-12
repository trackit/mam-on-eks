resource "helm_release" "phraseanet_stack" {
  name             = "phraseanet"
  chart            = "../phraseanet/helm/charts/phraseanet"
  namespace        = "phraseanet"
  create_namespace = true

  set {
    name  = "app.phraseanet_db_host"
    value = module.database.rds_address
  }

  set {
    name  = "app.phraseanet_rabbitmq_host"
    value = module.rabbitmq.rabbitmq_broker_ip
  }

  set {
    name  = "app.phraseanet_cache_host"
    value = module.elasticache.primary_endpoint
  }

  values = [file("../phraseanet/helm/myvalues.yaml")]

  wait    = false
  timeout = 300
}
