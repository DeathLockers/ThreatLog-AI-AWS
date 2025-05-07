#!/bin/sh

# Use $HOME instead of ~ for proper expansion
PRODUCER_LOGS_DATA="$HOME/deathlockers/logs"
export PRODUCER_LOGS_DATA

# Persist the variable for future terminal sessions
if ! grep -q "PRODUCER_LOGS_DATA" ~/.bashrc; then
  echo "export PRODUCER_LOGS_DATA=$PRODUCER_LOGS_DATA" >> ~/.bashrc
fi

# Create log directory
mkdir -p "$PRODUCER_LOGS_DATA"

# Download sample CSV log files
curl -fsSL https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-API/master/producer_logs/0448f4a8-e0f1-7052-63a8-8883ece693e0.csv \
  -o "$PRODUCER_LOGS_DATA/0448f4a8-e0f1-7052-63a8-8883ece693e0.csv"

curl -fsSL https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-API/master/producer_logs/04982418-c001-70b3-41ad-03ec1c7bf3ad.csv \
  -o "$PRODUCER_LOGS_DATA/04982418-c001-70b3-41ad-03ec1c7bf3ad.csv"

# Download Docker Compose and env files
DOCKER_COMPOSE_TEMPLATE="https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-AWS/master/<folder>/<file>"
HOME_DIR="$HOME/deathlockers"
COMPOSE_INCLUDE_FOLDER="$HOME_DIR/include_compose_files"
mkdir -p "$COMPOSE_INCLUDE_FOLDER"
MASTER_COMPOSE_FILE="$HOME_DIR/docker-compose.yml"
echo "include:" > "$MASTER_COMPOSE_FILE"

# Dynamic folder, static file
for folder in api kafka client model web; do
  file="docker-compose.yml"
  url=$(echo "$DOCKER_COMPOSE_TEMPLATE" | sed "s|<folder>|$folder|" | sed "s|<file>|$file|")
  echo "Downloading $url"
  if curl -fsSL "$url" -o "${COMPOSE_INCLUDE_FOLDER}/${folder}.yml"; then
    echo "- ${COMPOSE_INCLUDE_FOLDER}/${folder}.yml" >> "$MASTER_COMPOSE_FILE"
  else
    echo "Warning: Failed to download $url" >&2
  fi
done

# Static folder, dynamic file
folder="env_files"
for file in .env.api .env.producer .env.broker .env.kafka-ui .env.predictor .env.web; do
  url=$(echo "$DOCKER_COMPOSE_TEMPLATE" | sed "s|<folder>|$folder|" | sed "s|<file>|$file|")
  echo "Downloading $url"
  if ! curl -fsSL "$url" -o "${COMPOSE_INCLUDE_FOLDER}/${file}"; then
    echo "Warning: Failed to download $url" >&2
  fi
done

# Run Docker Compose
cd "$COMPOSE_INCLUDE_FOLDER" || exit 1
docker compose up -d
