# MAM Inside EKS

This documentation provides steps to deploy Phraseanet using Kubernetes instead of Docker Compose.

While Phraseanet's official documentation shows how to use Docker Compose, this guide will focus on deploying the services to a Kubernetes cluster.

P.S.: It was discovered that there's an helm chart to be used together with minikube.  
Using helm turned out as a plan B, though it became the main setup in this repo.  
### Overview

In Kubernetes, each service defined in the Docker Compose file becomes one or more objects (such as Pods, Deployments, Services) in the cluster.
### Services

The following services are discovered so far:

- `phraseanet-gateway`
- `phraseanet-db`
- `phraseanet-worker`
- `phraseanet-elasticsearch`
- `phraseanet-fpm`
- `phraseanet-rabbitmq`
- `phraseanet-redis`
- `phraseanet-redis-session`
- `phraseanet-setup`

They provide Dockerfiles to build the images locally. Also they share images through dockerhub profile alchemyfr.  
```bash
https://hub.docker.com/r/alchemyfr/phraseanet-fpm
https://hub.docker.com/r/alchemyfr/phraseanet-worker
https://hub.docker.com/r/alchemyfr/phraseanet-nginx
https://hub.docker.com/repository/docker/alchemyfr/phraseanet-db
https://hub.docker.com/repository/docker/alchemyfr/phraseanet-elasticsearch
```

The `gateway`, `phraseanet`, and `setup`services are the core components of the platform.  
The phraseanet service consumes a lot of resource units.
### Cluster Setup

We are deploying the services on an **EKS (Elastic Kubernetes Service)** cluster within the **Trackit AWS account** for testing purposes.
#### Initializing Terraform

First, initialize Terraform with the following command:
```bash
terraform init \
  -backend-config="bucket=sandbox-tf-states" \
  -backend-config="key=terraform-sandbox/mam-inside-eks-state" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=mam-inside-eks-tf-lock-table" \
  -backend-config="dynamodb_endpoint=https://dynamodb.us-west-2.amazonaws.com"
```
#### Preparing the AWS Resources

For this doc we are assuming a sandbox environment. And the access to the aws account is through the aws cli profile sandbox.

1. **Create an S3 Bucket for Terraform State**:
```bash
aws s3api create-bucket \
  --bucket sandbox-tf-states \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2 \
  --profile sandbox
```

2. **Add Tags to the S3 Bucket**:
```bash
aws s3api put-bucket-tagging \
  --bucket sandbox-tf-states \
  --tagging 'TagSet=[{Key=Environment,Value=sandbox},{Key=Owner,Value="Leandro Mota"},{Key=Project,Value=mam-inside-eks},{Key=Name,Value=sandbox-tf-states}]' \
  --profile sandbox
```

3. **Create a DynamoDB Table for Terraform Locking**:
```bash
aws dynamodb create-table \
  --table-name mam-inside-eks-tf-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2 \
  --profile sandbox
```

4. **Tag the DynamoDB Table**:
```bash
aws dynamodb tag-resource \
  --resource-arn arn:aws:dynamodb:us-west-2:576872909007:table/mam-inside-eks-tf-lock-table \
  --tags Key=Name,Value=mam-inside-eks-tf-lock-table Key=Environment,Value=sandbox Key=Owner,Value="Leandro Mota" Key=Project,Value=mam-inside-eks \
  --region us-west-2 \
  --profile sandbox
```

5. **Create a Secret for Terraform Variables in AWS Secrets Manager**:
```bash
aws secretsmanager create-secret \
  --region "us-west-2" \
  --profile sandbox \
  --name "eks-in-mam-tfvars" \
  --secret-string file://sandbox.tfvars \
  --tags '[{"Key":"Name", "Value":"eks-in-mam-tfvars"}, {"Key":"Owner", "Value":"Leandro Mota"}, {"Key":"Project", "Value":"mam-inside-eks"}]'
```

6. **Update the Secret (if necessary)**:
```bash
aws secretsmanager update-secret \
  --region "us-west-2" \
  --profile sandbox \
  --secret-id "eks-in-mam-tfvars" \
  --secret-string file://sandbox.tfvars
```
#### Running Terraform

Once the resources are prepared, you can run Terraform.
For this is necessary a aws cli profile configured with the necessary credentials, and tfvars file with the necessary values. There's a sample at **terraform** folder: `sample.tfvars`
So run:

```bash
terraform plan --out=plan.out -var-file="sandbox.tfvars"
terraform apply "plan.out"
```

If needed, set the AWS profile environment variable:

```bash
export AWS_PROFILE=sandbox
```
#### Configuring kubeconfig for EKS Access

After deploying, you will need to update the kubeconfig to interact with the EKS cluster:

```bash
aws eks --region us-west-2 update-kubeconfig \
  --name mam-sandbox \
  --kubeconfig ~/.kube/mam-sandbox-config \
  --profile sandbox
```
#### Using a UI Tool for Kubernetes Interactions

For easier interactions with the Kubernetes cluster, it is recommended to use a UI tool like [K8sLens](https://k8slens.dev/)
### Cluster Teardown

If necessary the EKS cluster can be destroyed after testing. To destroy the cluster, run the following command:

```bash
terraform plan -destroy -target module.eks \
  --out=plan.out \
  -var-file="sandbox.tfvars"
```
### Shutting Down Cluster Nodes (Optional)

If you prefer to save resources during off-hours, you can scale down the cluster nodes to zero:

```bash
export CLUSTER_NAME=mam-sandbox
eksctl scale nodegroup --cluster $CLUSTER_NAME --name $(eksctl get nodegroup --cluster $CLUSTER_NAME --profile sandbox -o json | jq -r '.[].Name') --nodes 0 --nodes-min 0 --nodes-max 10 --profile sandbox
```

To turn it on again just change the `--nodes` number above 0 and don't forget to also increase `--node-min` accordinly.  
### Phraseanet Setup

#### Docker Compose Setup

This is a work in progress.  
We initially used the **Kompose** tool to convert the **Docker Compose** files into **Kubernetes manifest** files.  

We need to test each service individually and verify its functionality.

Currently, the **dependencies** are not fully mapped, but some have been identified:

- **Database-dependent:**
    - Worker, Setup
- **FPM/Worker-dependent:**
    - Gateway
- **Frontend-dependent:**
    - Gateway

For reference, the Phraseanet GitHub page provides the **Docker Compose** setup and instructions for running the services:  
[Phraseanet GitHub Repository](https://github.com/alchemy-fr/Phraseanet)

Kubernetes objects involved for each service:  
- Gateway
  - Config Map
  - Persistent Volume
  - Deployment

After multiple attempts and upon discovering the Helm chart, we decided to try deploying using Helm, as detailed below.  
#### Helm Chart Setup

The Helm chart for Phraseanet is not updated as frequently as the main repository, which primarily focuses on Docker Compose. The chart is designed to run on Minikube, but with minor modifications, it can be deployed on any Kubernetes distribution.  
##### Steps to Deploy
1. The necessary files is at the folder helm.
2. The repository contains two Helm charts:
  - Phraseanet (the primary solution).
  - Phrasea (a newer solution).
3. We are using Phraseanet.
4. At the root folder run:
```bash
helm install phraseanet ./phraseanet -n phraseanet --create-namespace
```

The command will create a helm release inside the EKS cluster and afterward install all the necessary manifests for ther Phraseanet deploy.

You can follow the pods creation for each phraseanet service and they get deployed.
For some reason the `phraseanet-setup` service is not able to reach two database inside the mysql pod. The Alchemy image `phraseanet-db` used for the DB pod is meant to have these DB installed but they aren't.

So more things to do:
##### Steps to create the new databases inside the `phraseanet-db` :
1. Shell execute the `phraseanet-db` :
```bash

```
2. Inside the pod terminal run:
```bash
mysql -u root -p -e "CREATE DATABASE ab_master;"
mysql -u root -p -e "CREATE DATABASE db_databox1;"
```
The default password is the one passed inside the `values.yaml`
3. After this check if the two new databases were created:
```bash
mysql -u root -p -e "SHOW DATABASES;"
```

Now, the setup pod job should complete. If not, probably is because the job reached the maximum tries.
If this happens just destroy the pod that the job will run it again.

*The `phraseanet-saml` is right now not working due to some error in the image. Need to check other image versions

After the Helm setup and Phraseanet installation, we can start using the platform.

### Phraseanet post-installation

With everything deployed the platform frontend is available through `phraseanet-gateway` service.
Though we don't have it exposed publicly we can access it privately using Kubernetes Port Forwading.

For this run:
```bash
kubectl 
```

Now it's available at http://localhost on your browser at the port chosen.


### Next Steps

For now this deployment does only the basics.
Follows some next task to implement in the near future.

1. Integrate the manifests into terraform code
2. Integrate ALB using Kubernetes ingress into terraform code
3. Implement a integration between Kubernetes HPA with Karpenter vertical autoscaling
4. Create a vital monitoring using CloudWatch Stack, or a second option Kube-Stack (Prometheus + Grafana)
5. Phraseanet comes prepared to use new relic. Maybe test it
6. Adjust the IAC for a possible production environment
	1. Use a Managed DB Service (Amazon RDS)
	2. Use a Redis managed Service (Amazon ElastiCache)
	3. Use a ElasticSearch managed Service (Amazon OpenSearch)
	4. Use a RabbitMQ managed Service (Amazon MQ)
7. Knows Phraseanet MAM platform better to create a simple workflow to demo the use

