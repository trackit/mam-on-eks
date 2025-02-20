resource "helm_release" "phraseanet_stack" {
  name             = "phraseanet"
  chart            = "../phraseanet/helm/charts/phraseanet"
  namespace        = "phraseanet"
  create_namespace = true

  values = [file("../phraseanet/helm/myvalues.yaml")]

  wait    = false
  timeout = 300
}
