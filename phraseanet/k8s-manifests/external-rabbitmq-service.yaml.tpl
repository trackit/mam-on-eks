apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
  namespace: phraseanet
spec:
  type: ExternalName
  externalName: ${rabbitmq_host}
