# Deploy do CDN (modelo Hubbe: origin + Cloudflare)

Por que origin próprio e não jsDelivr puro: o **jsDelivr corta arquivos > 20 MB**, e
`FurnitureData.json` (26 MB) e `figure.zip` (32 MB) são carregados no boot do client.
Servir do seu próprio nginx + Cloudflare não tem esse limite — é o que o Hubbe faz.

```
Player ──► Cloudflare (cache/CDN global, grátis) ──► nginx na VPS ──► /var/www/cdn (git clone)
                                                                          ▲
                                                                  git pull (update.sh)
                                                                          │
                                                              GitHub: HabbitCorp/cdn
```

## 1. DNS / Cloudflare
- Adicione um registro **A**: `cdn.SEUDOMINIO.com → 178.253.250.79` (IP da VPS), **proxied** (nuvem laranja).
- SSL/TLS: comece em **Flexible** (funciona com o nginx :80). Depois suba pra **Full (strict)** com Origin Certificate.
- (Opcional) Caching → "Cache Everything" pro hostname do CDN.

## 2. VPS — clonar e servir
```bash
sudo git clone --depth 1 https://github.com/HabbitCorp/cdn /var/www/cdn
sudo cp /var/www/cdn/deploy/nginx-cdn.conf /etc/nginx/sites-available/cdn.conf
# edite o server_name e o root no arquivo, se necessário
sudo ln -s /etc/nginx/sites-available/cdn.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

Teste direto na origem (sem Cloudflare):
```bash
curl -I http://127.0.0.1/nitro-assets/gamedata/FurnitureData.json -H "Host: cdn.SEUDOMINIO.com"
# 200 + Access-Control-Allow-Origin: *
```

## 3. Apontar o client pro CDN
No client de produção (o servido pelo CMS), troque as URLs de asset:
```bash
cd /caminho/do/projeto
deploy/apply-cdn-urls.sh cdn.SEUDOMINIO.com cms/public/nitro-react/dist/renderer-config.json
```
Isso muda:
```
"asset.url":         "http://localhost:8000/nitro-assets" -> "https://cdn.SEUDOMINIO.com/nitro-assets"
"image.library.url": "http://localhost:8000/swf/c_images/" -> "https://cdn.SEUDOMINIO.com/swf/c_images/"
"hof.furni.url":     "http://localhost:8000/swf/dcr/hof_furni" -> "https://cdn.SEUDOMINIO.com/swf/dcr/hof_furni"
```
> `socket.url` (emulador) é separado — ajuste pra `wss://ws.SEUDOMINIO:porta` no deploy do emulador.
> Mantenha os configs locais apontando pra localhost (não rode o script neles).

## 4. Atualizar assets (furni novo / gamedata)
Adicione/atualize os arquivos no repo `cdn` (no seu Mac) e dê push. Na VPS:
```bash
/var/www/cdn/deploy/update.sh        # git pull --depth 1 + reset --hard
```
Automatize via cron (a cada 15 min):
```
*/15 * * * * /var/www/cdn/deploy/update.sh >> /var/log/cdn-update.log 2>&1
```
**Cache-busting:** ao mudar o gamedata, incremente o `?vN` no renderer-config
(`FurnitureData.json?13` -> `?14`) pra furar o cache do Cloudflare na hora.
Ou rode a purga do Cloudflare (trecho opcional no `update.sh`).

## 5. Checklist
- [ ] DNS `cdn.` apontando pra VPS, proxied no Cloudflare
- [ ] `git clone --depth 1` em /var/www/cdn
- [ ] nginx-cdn.conf instalado, `nginx -t` ok, reload
- [ ] curl na origem retorna 200 + CORS
- [ ] renderer-config de produção apontando pro CDN
- [ ] update.sh no cron
