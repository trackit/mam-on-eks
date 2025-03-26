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

  # depends_on = [module.eks] 
  # depends_on = [time_sleep.wait_for_eks]
  depends_on = [ kubectl_manifest.wait_for_nodes_job]
}

data "template_file" "job_setup_database_template" {
  template = file("../phraseanet/k8s-manifests/job-setup-database.yaml.tpl")

  vars = {
    rds_db_host          = "db"
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

#Service Account for the Cluster access the ALB resource
resource "kubectl_manifest" "aws_lb_controller_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws_lb_controller.arn}
YAML
  apply_only       = true
  wait_for_rollout = false

depends_on = [ 
  kubectl_manifest.wait_for_nodes_job
 ]

}