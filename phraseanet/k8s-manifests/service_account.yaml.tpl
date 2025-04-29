apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${name}
  namespace: phraseanet
  annotations:
    eks.amazonaws.com/role-arn: ${arn}
