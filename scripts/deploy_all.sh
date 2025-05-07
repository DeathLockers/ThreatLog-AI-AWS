#!/bin/sh

# Correctly expand ~ using $HOME instead of literal ~
PRODUCER_LOGS_DATA="$HOME/producer_logs"

DOCKER_COMPOSE_TEMPLATE="https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-AWS/master/<replace>/docker-compose.yml"

# Use $HOME instead of ~ for safe expansion in scripts
HOME_DIR="$HOME/deathlockers"
COMPOSE_INCLUDE_FOLDER="$HOME_DIR/include_compose_files"

mkdir -p "$COMPOSE_INCLUDE_FOLDER"

MASTER_COMPOSE_FILE="$HOME_DIR/docker-compose.yml"

echo "include:" > "$MASTER_COMPOSE_FILE"

# Download the docker-compose.yml files for each component
for name in api kafka client model; do
  url=$(echo "$DOCKER_COMPOSE_TEMPLATE" | sed "s|<replace>|$name|")
  curl -fsSL "$url" -o "${COMPOSE_INCLUDE_FOLDER}/${name}.yml"
  echo "- ${COMPOSE_INCLUDE_FOLDER}/${name}.yml" >> "$MASTER_COMPOSE_FILE"
done


# Setup env variables files
