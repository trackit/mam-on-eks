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

data "template_file" "external_rabbitmq_service_template" {
  template = file("../phraseanet/k8s-manifests/external-rabbitmq-service.yaml.tpl")

  vars = {
    rabbitmq_host = module.rabbitmq.rabbitmq_broker_ip
  }
}

resource "kubectl_manifest" "external_rabbitmq_service_manifest" {
  yaml_body        = data.template_file.external_rabbitmq_service_template.rendered
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}

data "template_file" "job_setup_database_template" {
  template = file("../phraseanet/k8s-manifests/job-setup-database.yaml.tpl")

  vars = {
    rds_db_host          = module.database.rds_address
    rds_db_root_password = var.database.password
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
}
