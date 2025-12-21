
# 1. HELM PROVIDER CONFIGURATION
# Connects Helm to EKS cluster using outputs from 'eks' module
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# 2. PROMETHEUS & GRAFANA DEPLOYMENT
# Deploys the full kube-prometheus-stack (Server, Grafana, Node Exporters)
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "51.2.0"

  # --- COST & RESOURCE OPTIMIZATION ---
  # Ideal for t4g.medium nodes (4GB RAM)
  
  # Reduce metric retention to 1 day to save EBS costs
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "1d"
  }

  # Use the gp3 storage class enabled in your 'eks' module
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp3"
  }

  # Minimal storage allocation
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "5Gi"
  }

  # --- GRAFANA PERSISTENCE ---
  # Ensures dashboards aren't lost if the pod restarts
  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = "gp3"
  }

  # --- ALB INGRESS CONFIGURATION ---
  # Automatically creates a public Application Load Balancer via the AWS ALB Controller
  
  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }

  set {
    name  = "grafana.ingress.ingressClassName"
    value = "alb"
  }

 # Merge into one ALB
  set {
    name = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
    value = "my-portfolio-group"
  }   

  set {
    name = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.order"
    value = "5"

  # Makes the ALB publicly accessible over the internet
  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }

  # Optimized for EKS: Routes traffic directly to pod IPs
  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }

  # Default AWS ALB DNS name
  set {
    name  = "grafana.ingress.hosts[0]"
    value = "" 
  }
}

# 3. OUTPUT THE INGRESS ADDRESS
output "grafana_url" {
  description = "The public DNS of the Grafana Load Balancer"
  value       = "Check 'kubectl get ingress -n monitoring' after provisioning is complete."
}
