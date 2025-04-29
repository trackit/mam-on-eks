resource "helm_release" "phraseanet_stack" {
  name             = "phraseanet"
  chart            = "../phraseanet/helm/charts/phraseanet"
  namespace        = "phraseanet"
  create_namespace = true

  set {
    name  = "mysql.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  set {
    name  = "rabbitmq.enabled"
    value = "false"
  }

  set {
    name = "redis.enabled"
    value = "false"
  }

  set {
    name  = "app.phraseanet_db_host"
    value = module.database.rds_address
  }

  set {
    name  = "app.phraseanet_rabbitmq_host"
    value = module.rabbitmq.rabbitmq_broker_ip
  }

  set {
    name = "app.phraseanet_rabbitmq_user"
    value = var.rabbit_mq.username
  }

  set {
    name = "app.phraseanet_rabbitmq_pass"
    value = var.rabbit_mq.password
  }

  set {
    name = "app.phraseanet_rabbitmq_ssl"
    value = "true"
  }

  set {
    name = "app.phraseanet_rabbitmq_port"
    value = "5671"
  }

  set {
    name  = "app.phraseanet_cache_host"
    value = module.elasticache.primary_endpoint
  }

  set {
    name  = "app.phraseanet_elasticsearch_host"
    value = module.elasticsearch.elasticsearch_endpoint
  }

  set {
    name = "app.phraseanet_admin_account_email"
    value = var.phraseanet_admin_account_email
  }

  set {
    name  = "app.phraseanet_admin_account_password"
    value = var.phraseanet_admin_account_password
  }

  values = [file("../phraseanet/helm/myvalues.yaml")]

  depends_on = [
    module.database,
    module.rabbitmq,
    module.elasticache,
    module.elasticsearch,
    kubectl_manifest.standard_sc,
    helm_release.alb-controller,
  ]

  wait    = false
  timeout = 300
}

resource "helm_release" "alb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  wait    = false
  timeout = 300

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = local.vpc_id
  }

  set {
    name  = "clusterName"
    value = var.cluster.name
  }

  set {
    name  = "enableCertManager"
    value = false
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [ 
    kubectl_manifest.aws_lb_controller_sa
  ]

}