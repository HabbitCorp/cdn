#!/usr/bin/env bash
# Atualiza o CDN na VPS a partir do GitHub (HabbitCorp/cdn).
# Rode após adicionar furni novo / atualizar gamedata, ou via cron.
#   chmod +x update.sh
#   crontab -e   ->   */15 * * * * /var/www/cdn/deploy/update.sh >> /var/log/cdn-update.log 2>&1
set -euo pipefail

CDN_DIR="/var/www/cdn"        # <-- onde clonou HabbitCorp/cdn
BRANCH="main"

cd "$CDN_DIR"
echo "[$(date '+%F %T')] atualizando CDN em $CDN_DIR ..."

# o clone é --depth 1: busca raso e força igualar exatamente ao remoto
git fetch --depth 1 origin "$BRANCH"
git reset --hard "origin/$BRANCH"
git clean -fd

echo "[$(date '+%F %T')] CDN agora em $(git rev-parse --short HEAD)"

# ── (Opcional) Purga o cache do Cloudflare após atualizar ──
# NÃO commite o token. Exporte-o no ambiente: export CF_TOKEN=...
# CF_ZONE="seu_zone_id"
# if [ -n "${CF_TOKEN:-}" ]; then
#   curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/purge_cache" \
#     -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" \
#     --data '{"purge_everything":true}' >/dev/null && echo "cache do Cloudflare purgado"
# fi
