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

  set {
    name  = "app.phraseanet_elasticsearch_host"
    value = module.elasticsearch.elasticsearch_endpoint
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
    kubectl_manifest.wait_for_nodes_job,
    kubectl_manifest.aws_lb_controller_sa
  ]

}