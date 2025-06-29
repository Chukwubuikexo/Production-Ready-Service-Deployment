# FastAPI Production Runbook

## Incident Response Procedures

### 1. Service Outage
```bash
# 1. Check service status
kubectl -n production get pods -l app=fastapi-app

# 2. View logs from failing pods
kubectl -n production logs -l app=fastapi-app --tail=100 --prefix

# 3. Check ingress routing
kubectl -n production get ingress fastapi-ingress
kubectl -n production describe ingress fastapi-ingress

# 4. Restart deployment if needed
kubectl -n production rollout restart deployment fastapi-app
```

### 2. High Error Rates
```bash
# 1. Check Prometheus metrics
kubectl -n monitoring port-forward svc/prometheus-operated 9090
# Open http://localhost:9090 and query:
# sum(rate(http_requests_total{status=~"5.."}[5m])) by (pod)

# 2. Isolate problematic pods
kubectl -n production get pods -l app=fastapi-app -o wide
kubectl -n production describe pod <problematic-pod>

# 3. Enable debug logging
kubectl -n production set env deployment/fastapi-app LOG_LEVEL=DEBUG

```

### 2. High Error Rates
```bash
# Manual rotation procedure

# 1. Update Kubernetes secret
kubectl -n production create secret generic fastapi-secrets \
  --from-literal=API_KEY=$NEW_API_KEY \
  --from-literal=DB_PASSWORD=$NEW_DB_PASS \
  --dry-run=client -o yaml | kubectl apply -f -


```

## 3. Performance Tuning
```bash
# View current metrics
kubectl -n production get hpa fastapi-hpa

# Adjust autoscaling parameters
kubectl -n production patch hpa fastapi-hpa -p \
  '{"spec":{"metrics":[{"resource":{"name":"cpu","target":{"averageUtilization":85,"type":"Utilization"}}}]}}'

```

### 4. Memory Optimization
```bash
# 1. Profile memory usage
kubectl -n production exec -it $(kubectl get pod -l app=fastapi-app -o jsonpath='{.items[0].metadata.name}') -- \
  pip install memray && python -m memray run -o /tmp/memray.bin app/main.py

# 2. Analyze memory leaks
kubectl -n production cp $(kubectl get pod -l app=fastapi-app -o jsonpath='{.items[0].metadata.name}'):/tmp/memray.bin .
```

### 5. Rollback Procedures
```bash
# 1. Identify last good revision
kubectl -n production rollout history deployment/fastapi-app

# 2. Execute rollback
kubectl -n production rollout undo deployment/fastapi-app --to-revision=<REVISION_NUMBER>

# 3. Verify
kubectl -n production rollout status deployment/fastapi-app

```