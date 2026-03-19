#!/bin/bash
set -e

VERSION=$(cat last_version_staging.txt)
PREVIOUS_VERSION=$(cat previous_version_staging.txt 2>/dev/null || echo "none")

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="eu-north-1"
ECR_REPO="myapp-staging"

APP_MESSAGE="Hello from STAGING!"
APP_ENV="staging"

echo "Deploying version: $VERSION"
echo "Previous version: $PREVIOUS_VERSION"

echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Pulling new image..."
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "Stopping old container..."
docker stop myapp || true
docker rm myapp || true

echo "Creating log directory..."
sudo mkdir -p /var/log/myapp
sudo chown ec2-user:ec2-user /var/log/myapp

echo "Starting new container..."
docker run -d --name myapp \
  -p 80:80 \
  -v /var/log/myapp:/logs \
  -e APP_MESSAGE="$APP_MESSAGE" \
  -e APP_ENV="$APP_ENV" \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "Waiting for app to start..."
sleep 5

echo "Running health check..."
if curl -s http://localhost/health | grep -q "ok"; then
    echo "Health check passed. Deployment successful."
else
    echo "Health check FAILED. Rolling back to previous version: $PREVIOUS_VERSION"

    if [ "$PREVIOUS_VERSION" = "none" ]; then
        echo "No previous version available. Cannot roll back."
        exit 1
    fi

    echo "Pulling previous image..."
    docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$PREVIOUS_VERSION

    echo "Stopping failed container..."
    docker stop myapp || true
    docker rm myapp || true

    echo "Starting previous version..."
    docker run -d --name myapp \
      -p 80:80 \
      $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$PREVIOUS_VERSION

    echo "Rollback complete."
    exit 1
fi

echo "Updating version history..."
echo $VERSION > previous_version_staging.txt

