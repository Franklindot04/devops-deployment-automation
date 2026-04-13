#!/bin/bash
set -e

# Load previous version from file
if [ ! -f previous_version_production.txt ]; then
  echo "❌ No previous version file found. Cannot rollback."
  exit 1
fi

PREVIOUS_VERSION=$(cat previous_version_production.txt)

echo "🔄 Rolling back to version: $PREVIOUS_VERSION"

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="us-east-1"
ECR_REPO="myapp"

# SSH into EC2 and perform rollback
ssh -o StrictHostKeyChecking=no -i ~/.ssh/groundnut.pem ec2-user@16.171.41.129 << EOF
  set -e

  echo "Stopping current container..."
  docker stop myapp || true
  docker rm myapp || true

  echo "Pulling previous version..."
  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
  docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$PREVIOUS_VERSION

  echo "Starting previous version..."
  docker run -d --name myapp \
    -p 80:80 \
    -v /var/log/myapp:/logs \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$PREVIOUS_VERSION
EOF

echo "✅ Rollback to version $PREVIOUS_VERSION complete."
