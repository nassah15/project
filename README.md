# Full-Stack Ecommerce Cloud Platform


A production-ready ecommerce ecosystem featuring a React frontend, Flask REST API, and PostgreSQL database. This project demonstrates a complete DevOps journey: from local containerization to automated CI/CD and cloud orchestration on AWS EKS via Terraform and Helm.


## Architectural Evolution


Local Development: Orchestrated with Docker Compose using hot-reloading for rapid iteration .
Container Optimization: Implemented multi-stage builds in Docker to reduce image sizes and minimize attack surfaces .
Cloud Orchestration: Transitioned from raw Kubernetes manifests to modular Helm charts for environment-specific configuration .
Infrastructure as Code: Provisioned a high-availability Three-Tier VPC and EKS Cluster using Terraform .
CI/CD: Automated the pipeline using GitHub Actions with OIDC, enabling secure, keyless deployments to Amazon ECR and EKS .


## Key Features


Infrastructure: AWS EKS with ARM-based (t4g.medium) managed node groups for cost-efficiency .
Networking: Automated AWS ALB (Application Load Balancer) provisioning via Ingress Controller for path-based routing (/ and /api) .
Security: OIDC-based identity federation for CI/CD and IRSA (IAM Roles for Service Accounts) to enforce least privilege .
Storage: Persistent ecommerce data using EBS CSI Driver and gp3 storage classes .
Observability: Integrated Prometheus and Grafana stack for real-time cluster monitoring .

## Project Structure

* [ecommerce-backend/](./ecommerce-backend) - Flask API & SQLAlchemy Models
* [ecommerce-frontend/](./ecommerce-frontend) - React (Vite) SPA & Routing
* [infra/terraform/](./infra/terraform) - EKS, VPC, OIDC, & IAM Policy Code
* [k8s/](./k8s) - Original raw manifests for local testing
* [helm/ecommerce/](./helm/ecommerce) - Templatable K8s manifests
* [.github/workflows/](./.github/workflows) - CI/CD Pipeline (Docker Build -> ECR -> Helm)
* [docker-compose.yml](./docker-compose.yml) - Local Dev environment
* [docker-compose.prod.yml](./docker-compose.prod.yml) - Local Production simulation

## Local Setup


### 1. Prerequisite
* Docker & Docker Compose
* A `.env` file in the root directory


### 2. Run with Docker Compose


```bash
# Start the full stack in development mode
docker-compose up --build


The frontend will be available at http://localhost:5173 and the backend at http://localhost:5001


---


## Cloud Deployment


###1. Infrastructure Provisioning


To provision the AWS resources using Terraform:


```bash
cd infra/terraform
terraform init
terraform apply


### 2. Manual Helm Installation (Optional)


If you prefer to deploy manually rather than via CI/CD, use the following command:


```bash
helm upgrade --install ecommerce ./helm/ecommerce -f helm/ecommerce/values-eks.yaml


## Monitoring


The monitoring stack is deployed via Helm in the 'monitoring' namespace.


* Prometheus: Handles metric collection with a 1-day retention period to optimize costs .
* Grafana: Exposed via a public ALB; provides dashboards for cluster health and application performance .


---


## Security Note


This project utilizes GitHub OIDC for AWS authentication, removing the need for static AWS_ACCESS_KEY_ID in repository secrets . All database credentials are managed via Kubernetes Secrets .
