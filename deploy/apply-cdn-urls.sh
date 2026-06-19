#!/usr/bin/env bash
# Troca as URLs de asset (localhost -> CDN) nos renderer-config.json.
# NÃO mexe em socket.url (isso é o emulador/WebSocket, não o CDN).
# Portável (macOS e Linux). Gera .bak de cada arquivo.
#
# Uso:
#   ./apply-cdn-urls.sh cdn.SEUDOMINIO.com  caminho/para/renderer-config.json [outro...]
#
# Exemplo (config de produção servido pelo CMS):
#   ./apply-cdn-urls.sh cdn.habbit.com  cms/public/nitro-react/dist/renderer-config.json
set -euo pipefail

DOMAIN="${1:?uso: $0 <dominio-cdn> <renderer-config.json...>}"
shift
CDN="https://$DOMAIN"

for f in "$@"; do
  [ -f "$f" ] || { echo "pulando (nao existe): $f"; continue; }
  cp "$f" "$f.bak"
  sed \
    -e "s|http://localhost:8000|$CDN|g" \
    -e "s|http://localhost/nitro-assets|$CDN/nitro-assets|g" \
    -e "s|http://localhost/swf|$CDN/swf|g" \
    "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "atualizado: $f  (backup: $f.bak)"
  grep -E '"(asset|flash\.asset|image\.library|hof\.furni)\.url"' "$f" | sed 's/^/    /'
done

echo
echo ">> socket.url NAO foi tocado (aponta pro emulador)."
echo ">> Em produção, ajuste socket.url separado para wss://ws.SEUDOMINIO:porta"
