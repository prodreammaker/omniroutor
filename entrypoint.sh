#!/bin/bash
set -e

if [ -z "$JWT_SECRET" ]; then
  echo "[WARN] JWT_SECRET not set — generating ephemeral value. Set it with: fly secrets set JWT_SECRET=..."
  export JWT_SECRET="$(openssl rand -base64 48)"
fi

if [ -z "$API_KEY_SECRET" ]; then
  echo "[WARN] API_KEY_SECRET not set — generating ephemeral value. Set it with: fly secrets set API_KEY_SECRET=..."
  export API_KEY_SECRET="$(openssl rand -hex 32)"
fi

if [ -z "$OMNIROUTE_WS_BRIDGE_SECRET" ]; then
  echo "[WARN] OMNIROUTE_WS_BRIDGE_SECRET not set — generating ephemeral value."
  export OMNIROUTE_WS_BRIDGE_SECRET="$(openssl rand -hex 32)"
fi

if [ -z "$STORAGE_ENCRYPTION_KEY" ] && [ -f "/app/data/server.env" ]; then
  # shellcheck disable=SC1091
  . /app/data/server.env || true
fi

if [ -z "$STORAGE_ENCRYPTION_KEY" ]; then
  echo "[WARN] STORAGE_ENCRYPTION_KEY is not set. Existing encrypted credentials may fail to decrypt."
fi

export PORT="${PORT:-8080}"
export HOSTNAME="0.0.0.0"
export INITIAL_PASSWORD="${INITIAL_PASSWORD:-omniroute}"
export DATA_DIR="${DATA_DIR:-/app/data}"
export AUTH_COOKIE_SECURE="${AUTH_COOKIE_SECURE:-true}"
export NODE_ENV="${NODE_ENV:-production}"
export STORAGE_DRIVER="${STORAGE_DRIVER:-sqlite}"

if [ -n "$FLY_APP_NAME" ]; then
  export NEXT_PUBLIC_BASE_URL="https://${FLY_APP_NAME}.fly.dev"
  export BASE_URL="https://${FLY_APP_NAME}.fly.dev"
else
  export NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://0.0.0.0:${PORT}}"
  export BASE_URL="${BASE_URL:-${NEXT_PUBLIC_BASE_URL}}"
fi

mkdir -p "$DATA_DIR"

echo "================================================"
echo " OmniRoute starting on port $PORT"
echo " Dashboard: ${NEXT_PUBLIC_BASE_URL}"
echo " Data dir:  $DATA_DIR (persistent Fly volume)"
echo "================================================"

exec node dev/run-standalone.mjs
