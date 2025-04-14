resource "helm_release" "phraseanet_stack" {
  name             = "phraseanet"
  chart            = "../phraseanet/helm/charts/phraseanet"
  namespace        = "phraseanet"
  create_namespace = true

  values = [file("../phraseanet/helm/myvalues.yaml")]
  wait    = false
  timeout = 300

  set {
    name = "app.phraseanet_admin_account_email"
    value = var.phraseanet_admin_account_email
  }

  set {
    name  = "app.phraseanet_admin_account_password"
    value = var.phraseanet_admin_account_password
  }

  depends_on = [ 
    kubectl_manifest.standard_sc,
    helm_release.alb-controller
   ]
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
    name  = "enableCertManager"
    value = false
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "app.phraseanet_admin_account_email"
    value = var.phraseanet_admin_account_email
  }

  set {
    name  = "app.phraseanet_admin_account_password"
    value = var.phraseanet_admin_account_password
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [ 
    kubectl_manifest.aws_lb_controller_sa
  ]

}