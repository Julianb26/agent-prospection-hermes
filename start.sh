#!/bin/bash
set -e

mkdir -p /root/.hermes

{
  echo "OPENROUTER_API_KEY=${OPENROUTER_API_KEY}"
  echo "DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}"
  echo "DISCORD_ALLOWED_USERS=${DISCORD_ALLOWED_USERS}"
} >> /root/.hermes/.env

exec /usr/local/bin/hermes gateway run
