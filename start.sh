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

# Forcer le modèle : le config.yaml de Railway est régénéré à neuf à chaque build,
# avec un modèle payant par défaut (anthropic/claude-opus-4.6) -> erreur HTTP 402
# si le compte OpenRouter n'a pas de crédits. On force donc un modèle gratuit.
# (Modifiable via la variable Railway HERMES_MODEL si besoin.)
MODEL="${HERMES_MODEL:-nvidia/nemotron-3-super-120b-a12b:free}"
echo "[start.sh] Reglage du modele par defaut: ${MODEL}"
/usr/local/bin/hermes config set model.default "${MODEL}" || true
/usr/local/bin/hermes config set model.provider openrouter || true
/usr/local/bin/hermes config set model.base_url "https://openrouter.ai/api/v1" || true

# Répondre directement dans le canal principal plutôt que de créer un fil (thread)
# pour chaque conversation. Mettre HERMES_AUTO_THREAD=true pour revenir aux fils.
AUTO_THREAD="${HERMES_AUTO_THREAD:-false}"
echo "[start.sh] discord.auto_thread = ${AUTO_THREAD}"
/usr/local/bin/hermes config set discord.auto_thread "${AUTO_THREAD}" || true

exec /usr/local/bin/hermes gateway run
