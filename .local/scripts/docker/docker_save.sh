#!/bin/bash

# Экспорт образа в формат tar

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

IMAGE_ID=$(docker inspect --format='{{.Image}}' "$CONTAINER_NAME" 2>/dev/null)

if [ -z "$IMAGE_ID" ]; then
  echo "ERR: '$CONTAINER_NAME' not found."
  exit 2
fi

IMAGE_TAG=$(docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep "$IMAGE_ID" | awk '{print $1}' | head -n 1)

if [ -n "$IMAGE_TAG" ]; then
  SAFE_TAG=$(echo "$IMAGE_TAG" | sed 's/[^a-zA-Z0-9_.-]/_/g')
  OUTPUT_FILE="${CONTAINER_NAME}_${SAFE_TAG}_${TIMESTAMP}.tar"
else
  echo "Warning: Could not fount image tag. Usage $IMAGE_ID."
  SHORT_ID=${IMAGE_ID:0:19}
  OUTPUT_FILE="${CONTAINER_NAME}_${SHORT_ID}_${TIMESTAMP}.tar"
  IMAGE_TAG="$IMAGE_ID"
fi

docker save -o "$OUTPUT_FILE" "$IMAGE_TAG"

if [ $? -eq 0 ]; then
  echo "'$OUTPUT_FILE' saved."
else
  echo "Save error."
  exit 3
fi
