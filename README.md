# MAM Inside EKS

This documentation provides steps to deploy Phraseanet using Kubernetes instead of Docker Compose. 
While Phraseanet's official documentation shows how to use Docker Compose, this guide will focus on deploying the services to a Kubernetes cluster.

P.S.: It was discovered that there's an unofficial helm chart to be used together with minikube.  
Using helm is a plan B.

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

https://hub.docker.com/repository/docker/alchemyfr/phraseanet-elasticsearch```
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

1. **Create a DynamoDB Table for Terraform Locking**:

```bash
aws dynamodb create-table \
  --table-name mam-inside-eks-tf-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2 \
  --profile sandbox
```

2. **Tag the DynamoDB Table**:

```bash
aws dynamodb tag-resource \
  --resource-arn arn:aws:dynamodb:us-west-2:576872909007:table/mam-inside-eks-tf-lock-table \
  --tags Key=Name,Value=mam-inside-eks-tf-lock-table Key=Environment,Value=sandbox Key=Owner,Value="Leandro Mota" Key=Project,Value=mam-inside-eks \
  --region us-west-2 \
  --profile sandbox
```

3. **Create a Secret for Terraform Variables in AWS Secrets Manager**:

```bash
aws secretsmanager create-secret \
  --region "us-west-2" \
  --profile sandbox \
  --name "eks-in-mam-tfvars" \
  --secret-string file://sandbox.tfvars \
  --tags '[{"Key":"Name", "Value":"eks-in-mam-tfvars"}, {"Key":"Owner", "Value":"Leandro Mota"}, {"Key":"Project", "Value":"mam-inside-eks"}]'
```

4. **Update the Secret (if necessary)**:

```bash
aws secretsmanager update-secret \
  --region "us-west-2" \
  --profile sandbox \
  --secret-id "eks-in-mam-tfvars" \
  --secret-string file://sandbox.tfvars
```

#### Running Terraform

Once the resources are prepared, you can run Terraform:

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

As this work is experimental, the EKS cluster will be destroyed after testing. To destroy the cluster, run the following command:

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
1. Clone the repository (link here).
2. The repository contains two Helm charts:
  - Phraseanet (the primary solution).
  - Phrasea (a newer solution).
3. We are using Phraseanet. To better understand its deployment structure, we copied the Helm templates into this repository inside Phraseanet/helm.
