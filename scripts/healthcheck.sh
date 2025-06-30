#!/bin/bash
#localhost
ENDPOINT="http://localhost:8000/health"
for i in {1..10}; do
  response=$(curl -s -o /dev/null -w "%{http_code}" $ENDPOINT)
  [ "$response" -eq 200 ] && exit 0
  sleep 5
done
exit 1


#local testing
ENDPOINT="http://$(minikube ip):$(kubectl get svc fastapi-service -o jsonpath='{.spec.ports[0].nodePort}')/health"


#cluster terminal check
ENDPOINT="http://fastapi-service.default.svc.cluster.local/health"







#!/bin/bash
# Production health check with timeout and retries

ENDPOINT="${HEALTH_CHECK_ENDPOINT:-http://fastapi-service.default.svc.cluster.local/health}"
MAX_RETRIES=10
RETRY_DELAY=5
TIMEOUT=3

for i in $(seq 1 $MAX_RETRIES); do
  if response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT $ENDPOINT); then
    if [ "$response" -eq 200 ]; then
      echo "Health check passed"
      exit 0
    fi
  fi
  echo "Attempt $i/$MAX_RETRIES failed - Retrying in $RETRY_DELAY seconds..."
  sleep $RETRY_DELAY
done

echo "Health check failed after $MAX_RETRIES attempts"
exit 1