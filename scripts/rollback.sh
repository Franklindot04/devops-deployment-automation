#!/bin/bash
set -e

PREVIOUS_VERSION=$1

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="us-east-1"
ECR_REPO="myapp"
EC2_HOST="16.171.41.129"
SSH_KEY_PATH="~/.ssh/groundnut.pem"

if [ -z "$PREVIOUS_VERSION" ]; then
  echo "Usage: ./rollback.sh <previous_version>"
  exit 1
fi

ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ec2-user@$EC2_HOST << EOF
  set -e

  docker stop myapp || true
  docker rm myapp || true

  docker run -d --name myapp -p 80:80 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$PREVIOUS_VERSION
EOF

echo "Rollback to version $PREVIOUS_VERSION complete."
