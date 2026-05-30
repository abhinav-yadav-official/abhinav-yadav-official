#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-${HOST:-abhiyadav.in}}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOMAIN="${DOMAIN:-abhiyadav.in}"
WEB_ROOT="${WEB_ROOT:-/var/www/html}"
REMOTE_PATH="${REMOTE_PATH:-$WEB_ROOT/github-profile}"

require_local() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing local command: $1" >&2
    exit 1
  fi
}

quote() {
  printf "%q" "$1"
}

require_local ssh
require_local rsync

for asset in retro-terminal.svg project-arcade.svg typing.svg; do
  test -s "$ROOT/assets/$asset" || {
    echo "missing asset: assets/$asset" >&2
    exit 1
  }
done

echo "deploying GitHub profile assets to $HOST:$REMOTE_PATH"

ssh "$HOST" "mkdir -p $(quote "$REMOTE_PATH")"
rsync -az --delete \
  --include='*.svg' \
  --exclude='*' \
  "$ROOT/assets"/ "$HOST:$REMOTE_PATH"/

ssh "$HOST" "find $(quote "$REMOTE_PATH") -type f -name '*.svg' -exec gzip -9 -kf {} \\;"

for asset in retro-terminal.svg project-arcade.svg typing.svg; do
  curl -fsS "https://$DOMAIN/github-profile/$asset" >/dev/null
done

echo "profile assets: https://$DOMAIN/github-profile/"
