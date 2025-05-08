#!/bin/bash

set -e

BASE_DIR="$HOME/threatlog_ai"
LOGS_DIR="$BASE_DIR/logs"
COMPOSE_DIR="$BASE_DIR/compose_files"
MAIN_COMPOSE="$BASE_DIR/docker-compose.yml"
ENV_SOURCE="https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-AWS/master"

export PRODUCER_LOGS_DATA="$LOGS_DIR"
if ! grep -q "PRODUCER_LOGS_DATA=" ~/.bashrc; then
  echo "export PRODUCER_LOGS_DATA=$PRODUCER_LOGS_DATA" >> ~/.bashrc
fi

mkdir -p "$LOGS_DIR" "$COMPOSE_DIR"

curl -fsSL https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-API/master/producer_logs/0448f4a8-e0f1-7052-63a8-8883ece693e0.csv -o "$LOGS_DIR/log1.csv"
curl -fsSL https://raw.githubusercontent.com/DeathLockers/ThreatLog-AI-API/master/producer_logs/04982418-c001-70b3-41ad-03ec1c7bf3ad.csv -o "$LOGS_DIR/log2.csv"

echo "include:" > "$MAIN_COMPOSE"

SERVICES=(api kafka client model web)
for service in "${SERVICES[@]}"; do
  compose_url="$ENV_SOURCE/$service/docker-compose.yml"
  target_file="$COMPOSE_DIR/$service.yml"
  if curl -fsSL "$compose_url" -o "$target_file"; then
    echo "- $target_file" >> "$MAIN_COMPOSE"
  else
    echo "Error al descargar $compose_url" >&2
  fi
done

ENV_FILES=(.env.api .env.producer .env.broker .env.kafka-ui .env.predictor .env.web)
for env in "${ENV_FILES[@]}"; do
  env_url="$ENV_SOURCE/env_files/$env"
  if ! curl -fsSL "$env_url" -o "$COMPOSE_DIR/$env"; then
    echo "Error al descargar $env_url" >&2
  fi
done

jwt="JWT_SECRET_KEY=$(openssl rand -hex 32)"
sed -i '/^JWT_SECRET_KEY=.*/d' "$COMPOSE_DIR/.env.api"
echo "$jwt" >> "$COMPOSE_DIR/.env.api"

public_ip=$(curl -s https://ifconfig.me)
sed -i "s|<host>|$public_ip|g" "$COMPOSE_DIR/.env.web"

cd "$COMPOSE_DIR"
docker compose -f "$MAIN_COMPOSE" up -d

sleep 5
docker exec threatlog-ai-api python -m app.db.migration

echo "Despliegue completado."