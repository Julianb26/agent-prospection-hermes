#!/bin/bash
set -e

echo "[start.sh] HOME=$HOME"
echo "[start.sh] whoami=$(whoami)"
echo "[start.sh] ---- runtime env var NAMES (values hidden) ----"
env | cut -d= -f1 | sort | sed 's/^/[start.sh] env: /'
echo "[start.sh] ---- end env var NAMES ----"
echo "[start.sh] OPENROUTER_API_KEY length: ${#OPENROUTER_API_KEY}"
echo "[start.sh] DISCORD_BOT_TOKEN length: ${#DISCORD_BOT_TOKEN}"
echo "[start.sh] DISCORD_ALLOWED_USERS value: ${DISCORD_ALLOWED_USERS}"
echo "[start.sh] RAILWAY_TEST canary value: ${RAILWAY_TEST}"

mkdir -p /root/.hermes

{
  echo "OPENROUTER_API_KEY=${OPENROUTER_API_KEY}"
  echo "DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}"
  echo "DISCORD_ALLOWED_USERS=${DISCORD_ALLOWED_USERS}"
} >> /root/.hermes/.env

exec /usr/local/bin/hermes gateway run
