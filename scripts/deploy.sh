#!/bin/bash
set -e

VERSION=$(cat last_version.txt)

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="us-east-1"
ECR_REPO="myapp"
EC2_HOST="16.171.41.129"
SSH_KEY_PATH="~/.ssh/groundnut.pem" # update this if your key is elsewhere

echo "Deploying version: $VERSION to EC2: $EC2_HOST"

ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ec2-user@$EC2_HOST << EOF
  set -e

  echo "Logging in to ECR..."
  aws ecr get-login-password --region $AWS_REGION \
    | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

  echo "Pulling image..."
  docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

  echo "Stopping old container..."
  docker stop myapp || true
  docker rm myapp || true

  echo "Starting new container..."
  docker run -d --name myapp -p 80:80 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

  echo "Deployment complete."
EOF
