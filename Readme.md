# Production-Ready FastAPI Deployment

## Overview
This document details the production deployment of a FastAPI application with Kubernetes, including setup instructions, encountered issues, and their resolutions.
 

### Software Requirements
```bash
# Required tools
minikube version >= v1.32.0
kubectl version >= v1.28.0
helm version >= v3.12.0
docker version >= 20.10.0
python >= 3.11
````

## Setup Instructions

### 1. Local Development Setup

```bash
# Clone repository
git clone https://github.com/yourrepo/fastapi-production.git
cd fastapi-production

# Create Python virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### 2. Docker Build

```bash
docker build -t fastapi-app:prod .

# Common error 1: Build fails due to missing dependencies
# Solution: Ensure requirements.txt includes all necessary packages

```

### 3. Kubernetes Deployment

```bash
# Start Minikube cluster
minikube start 

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Deploy application
kubectl apply -f production-deployment/k8s/

# Verify deployment
kubectl get pods -w
```

### 4. Access Application

```bash
# Get Minikube IP
minikube ip

# Create temporary ingress route (for testing)
kubectl port-forward service/fastapi-service 8080:80

# Access health check
curl http://localhost:8080/health
```


## Common Issues & Solutions

### Issue 1: Image Pull Backoff

**Symptoms**:

* Pods stuck in `ImagePullBackOff` status
* `kubectl describe pod` shows authentication errors

**Solution**:

```bash
# For Minikube, ensure you're using the local Docker env
eval $(minikube docker-env)
docker build -t fastapi-app:prod .

# For production clusters:
docker tag fastapi-app:prod your-registry/fastapi-app:prod
docker push your-registry/fastapi-app:prod
```

### Issue 2: CrashLoopBackOff

**Symptoms**:

* Pods restarting continuously
* Application logs show errors

**Debugging Steps**:

```bash
# Check pod logs
kubectl logs <pod-name> --previous

# Common causes:
# 1. Missing environment variables
#    Solution: Verify configmap and secret mounts
# 2. Permission issues
#    Solution: Check securityContext in deployment.yaml
# 3. Health check failures
#    Solution: Adjust liveness/readiness probe thresholds
```

### Issue 3 : Autoscaling Failure during Load Test


**Solution**:

1. Clean up existing test pods
2. Test Connectivity with full DNS name



### Issue 4 : Grafana port already in use on host machine not in k8s

**Solution**
1. Stop host Grafana process and port-forward again



### Added Security Measures
1. Set port range in network policies
2. Specific permission for service account
3. Used SealedSecrets in secret.yaml 
4. security updates in dockerfile builder stage
5. filesystem read-only where possible 
6. Must run as NonRootUser setting in pod-security.yaml 
7. Vulnerabilities scan in workflows/deploy.yaml


## Monitoring & Maintenance

### Accessing Monitoring Tools

```bash
# Prometheus
kubectl port-forward svc/ prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring


# Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

#To view dashboard in grafana localhost: import dashboard code from grafana-dashboard.json and set Prometheus data source to prometheus. Click Import

#AlertManger
kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n monitoring

```
