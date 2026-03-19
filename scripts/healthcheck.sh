#!/bin/bash
set -e

EC2_HOST="16.171.41.129"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EC2_HOST/health)

if [ "$STATUS" -ne 200 ]; then
  echo "Health check failed with status: $STATUS"
  exit 1
fi

echo "Service is healthy."
