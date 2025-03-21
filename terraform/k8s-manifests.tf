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

  depends_on = [module.eks] 
}

resource "kubectl_manifest" "ingressclass_manifest" {
  yaml_body        = file("../phraseanet/k8s-manifests/ingressclass.yaml")
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }

  depends_on = [module.eks] 
}

data "template_file" "job_setup_database_template" {
  template = file("../phraseanet/k8s-manifests/job-setup-database.yaml.tpl")

  vars = {
    rds_db_host          = "db.phraseanet.svc.cluster.local"
    rds_db_root_password = "phraseanet"
  }
}

resource "kubectl_manifest" "job_setup_database_manifest" {
  yaml_body        = data.template_file.job_setup_database_template.rendered
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }

  depends_on = [ helm_release.phraseanet_stack ]
}
