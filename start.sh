#!/bin/bash
set -e

# Identifiant Discord autorisé. On prend la variable Railway si elle est fournie,
# sinon on retombe sur l'ID connu (un ID Discord n'est PAS une donnée secrète).
ALLOWED_USERS="${DISCORD_ALLOWED_USERS:-700267933410000916}"

echo "[start.sh] OPENROUTER_API_KEY length: ${#OPENROUTER_API_KEY}"
echo "[start.sh] DISCORD_BOT_TOKEN length: ${#DISCORD_BOT_TOKEN}"
echo "[start.sh] DISCORD_ALLOWED_USERS (effectif): ${ALLOWED_USERS}"

mkdir -p /root/.hermes

{
  echo "OPENROUTER_API_KEY=${OPENROUTER_API_KEY}"
  echo "DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}"
  echo "DISCORD_ALLOWED_USERS=${ALLOWED_USERS}"
} >> /root/.hermes/.env

exec /usr/local/bin/hermes gateway run
