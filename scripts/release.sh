#!/bin/bash
set -e

# Load token from .env file
if [ -f .env ]; then
  export GITHUB_TOKEN=$(grep GITHUB_TOKEN .env | cut -d '=' -f2 | tr -d '\n\r ')
fi

# Verify token is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN not found in .env file"
  exit 1
fi

echo "GITHUB_TOKEN loaded (length: ${#GITHUB_TOKEN})"

# Run release-it
release-it
