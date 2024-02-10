#!/bin/bash

# Define the volume path dynamically based on the current directory
PROJECT_DIR=$(basename "$PWD")

# Replace placeholders in the template and output to docker-compose.yml
sed "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_DIR/g" scripts/docker-compose_template.yml > docker-compose.yml

echo "docker-compose.yml has been updated."
