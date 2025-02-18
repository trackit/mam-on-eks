data "kubectl_path_documents" "standard_sc" {
  pattern = "../phraseanet/k8s-manifests/storageclass.yaml"
}

# resource "kubectl_manifest" "standard_sc" {
#   for_each         = toset(data.kubectl_path_documents.standard_sc.documents)
#   yaml_body        = each.value
#   apply_only       = true
#   wait_for_rollout = false

#   lifecycle {
#     ignore_changes = [
#       yaml_body
#     ]
#   }
# }

resource "kubectl_manifest" "standard_sc" {
  for_each = toset([
    templatefile("../phraseanet/k8s-manifests/storageclass.yaml", {
      owner        = var.owner
      project      = var.project
    })
  ])

  yaml_body        = each.value
  apply_only       = true
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}