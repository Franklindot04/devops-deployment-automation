#!/bin/bash
set -e

# Load the last built version
VERSION=$(cat last_version.txt)
IMAGE="myapp:$VERSION"

AWS_ACCOUNT_ID="787124622426"
AWS_REGION="us-east-1"
ECR_REPO="myapp"

echo "Logging in to AWS ECR..."
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Tagging image..."
docker tag $IMAGE $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "Pushing image to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$VERSION

echo "Push complete: $VERSION"
