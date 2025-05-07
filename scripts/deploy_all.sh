#!/bin/sh

# Expand HOME properly
PRODUCER_LOGS_DATA="$HOME/producer_logs"
export PRODUCER_LOGS_DATA=$PRODUCER_LOGS_DATA

echo export PRODUCER_LOGS_DATA="$PRODUCER_LOGS_DATA"

source ~/.bashrc  # or source ~/.bash_profile

DOCKER_COMPOSE_TEMPLATE="https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-AWS/master/<folder>/<file>"

HOME_DIR="$HOME/deathlockers"
COMPOSE_INCLUDE_FOLDER="$HOME_DIR/include_compose_files"

mkdir -p "$COMPOSE_INCLUDE_FOLDER"

MASTER_COMPOSE_FILE="$HOME_DIR/docker-compose.yml"
echo "include:" > "$MASTER_COMPOSE_FILE"

# First loop: dynamic folder, static file
file="docker-compose.yml"
for folder in api kafka client model web; do
  url=$(echo "$DOCKER_COMPOSE_TEMPLATE" | sed "s|<folder>|$folder|" | sed "s|<file>|$file|")
  echo "Downloading $url"
  if curl -fsSL "$url" -o "${COMPOSE_INCLUDE_FOLDER}/${folder}.yml"; then
    echo "- ${COMPOSE_INCLUDE_FOLDER}/${folder}.yml" >> "$MASTER_COMPOSE_FILE"
  else
    echo "Warning: Failed to download $url" >&2
  fi
done

# Second loop: static folder, dynamic file
folder="env_files"
for file in .env.api .env.producer .env.broker .env.kafka-ui .env.producer .env.predictor .env.web; do
  url=$(echo "$DOCKER_COMPOSE_TEMPLATE" | sed "s|<folder>|$folder|" | sed "s|<file>|$file|")
  echo "Downloading $url"
  if ! curl -fsSL "$url" -o "${COMPOSE_INCLUDE_FOLDER}/${file}"; then
    echo "Warning: Failed to download $url" >&2
  fi
done

cd $COMPOSE_INCLUDE_FOLDER

docker compose up -d