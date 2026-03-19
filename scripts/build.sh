#!/bin/bash
set -e

VERSION=$(date +"%Y%m%d%H%M")
echo $VERSION > last_version.txt

docker buildx build \
  --platform linux/amd64 \
  -t myapp:$VERSION \
  -f app/Dockerfile \
  app/
