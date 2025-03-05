data "template_file" "standard_sc" {
  template = file("../phraseanet/k8s-manifests/storageclass.yaml.tpl")

  vars = {
    owner   = var.owner
    project = var.project
  }
}

resource "kubectl_manifest" "standard_sc" {
  yaml_body        = data.template_file.standard_sc.rendered
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}

data "template_file" "storageclass_template" {
  template = file("../phraseanet/k8s-manifests/ingressclass.yaml")
}

resource "kubectl_manifest" "storageclass_manifest" {
  yaml_body        = data.template_file.storageclass_template.rendered
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}
