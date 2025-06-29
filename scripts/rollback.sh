#!/bin/bash
REVISION=$(kubectl rollout history deployment/fastapi-app | tail -2 | head -1 | awk '{print $1}')
kubectl rollout undo deployment/fastapi-app --to-revision=$REVISION