#!/bin/bash
set -e

if [ -z "$VERSION" ]; then
  echo "❌ No version provided to rollback script."
  exit 1
fi

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="eu-north-1"
ECR_REPO="myapp-production"

echo "🔄 Rolling back to version: $VERSION"

echo "Stopping current container..."
docker stop myapp || true
docker rm myapp || true

echo "Pulling version..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "Starting container..."
docker run -d --name myapp \
  -p 80:80 \
  -v /var/log/myapp:/logs \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "✅ Rollback to version $VERSION complete."

