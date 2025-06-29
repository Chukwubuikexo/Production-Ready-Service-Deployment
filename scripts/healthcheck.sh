#!/bin/bash
ENDPOINT="https://api.example.com/health"
for i in {1..10}; do
  response=$(curl -s -o /dev/null -w "%{http_code}" $ENDPOINT)
  [ "$response" -eq 200 ] && exit 0
  sleep 5
done
exit 1