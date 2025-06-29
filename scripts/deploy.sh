#!/bin/bash
set -e
kubectl apply -f k8s/ --recursive
kubectl rollout status deployment/fastapi-app