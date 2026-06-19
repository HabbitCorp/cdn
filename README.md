# HabbitCorp CDN

Assets estáticos do hotel (cliente Nitro + Flash legado), servidos como CDN — modelo Hubbe.

## Estrutura
- `nitro-assets/` — cliente Nitro
  - `bundled/` — `.nitro` (furniture, figure, effect, pet, generic)
  - `gamedata/` — FigureData / FurnitureData / ProductData / etc.
  - `images/`, `sounds/`, `logos/`
- `swf/` — Flash legado (gordon, dcr/hof_furni, c_images, gamedata)
- `frank/` — GIFs do mascote

## Como servir

**Opção A — jsDelivr (grátis, sem servidor):**
```
https://cdn.jsdelivr.net/gh/HabbitCorp/cdn@main/nitro-assets/...
https://cdn.jsdelivr.net/gh/HabbitCorp/cdn@main/swf/...
```

**Opção B — origin próprio + Cloudflare (modelo Hubbe):**
`git clone --depth 1` no servidor + Cloudflare na frente do domínio.

## renderer-config.json
```json
"asset.url":         "https://<cdn>/nitro-assets",
"image.library.url": "https://<cdn>/swf/c_images/",
"hof.furni.url":     "https://<cdn>/swf/dcr/hof_furni"
```
> Cache-busting: incremente `?vN` em FurnitureData/FigureData ao atualizar o gamedata.
