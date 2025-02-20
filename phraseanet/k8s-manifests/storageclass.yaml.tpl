apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  fsType: ext4
  type: gp2
  tagSpecification_1: "Owner=${owner}"
  tagSpecification_2: "Project=${project}"
  # tagSpecification_3: "Name=eks-nodes-storage"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer