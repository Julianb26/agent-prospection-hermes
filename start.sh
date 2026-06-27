#!/bin/bash
set -e

echo "[start.sh] HOME=$HOME"
echo "[start.sh] whoami=$(whoami)"
echo "[start.sh] OPENROUTER_API_KEY length: ${#OPENROUTER_API_KEY}"
echo "[start.sh] DISCORD_BOT_TOKEN length: ${#DISCORD_BOT_TOKEN}"
echo "[start.sh] DISCORD_ALLOWED_USERS value: ${DISCORD_ALLOWED_USERS}"

mkdir -p /root/.hermes

{
  echo "OPENROUTER_API_KEY=${OPENROUTER_API_KEY}"
  echo "DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}"
  echo "DISCORD_ALLOWED_USERS=${DISCORD_ALLOWED_USERS}"
} >> /root/.hermes/.env

echo "[start.sh] Keys now present in /root/.hermes/.env:"
grep -o '^[A-Z_]*=' /root/.hermes/.env | sort -u || true

exec /usr/local/bin/hermes gateway run
