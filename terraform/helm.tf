resource "helm_release" "phraseanet_stack" {
  name             = "phraseanet"
  chart            = "../phraseanet/helm/charts/phraseanet"
  namespace        = "phraseanet"
  create_namespace = true

  values = [file("../phraseanet/helm/myvalues.yaml")]
  wait    = false
  timeout = 300

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