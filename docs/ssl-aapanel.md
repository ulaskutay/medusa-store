# SSL (aaPanel) — API + Storefront

Let's Encrypt **IP adresine** sertifika vermez. İki alt alan adı kullanın:

| Servis    | Örnek domain        | PM2 / Node hedef      |
|-----------|---------------------|------------------------|
| Storefront | `shop.senindomain.com` | `http://127.0.0.1:3001` |
| API + Admin | `api.senindomain.com`  | `http://127.0.0.1:9000` |

DNS: Her iki domain için **A kaydı** → `91.98.120.228`

---

## 1) aaPanel — iki site (reverse proxy)

**Önemli:** Storefront’u aaPanel Node projesi olarak **tekrar çalıştırmayın**. Sadece PM2 (`medusa-storefront`) çalışsın; panel sadece Nginx proxy + SSL yapsın.

### Site A — Mağaza

1. **Website** → **Add site** → `shop.senindomain.com`
2. **Reverse proxy** → hedef: `http://127.0.0.1:3001`
3. **SSL** → **Let's Encrypt** → Apply → **Force HTTPS** aç

### Site B — API / Admin

1. **Add site** → `api.senindomain.com`
2. Reverse proxy → `http://127.0.0.1:9000`
3. Let's Encrypt + Force HTTPS

Şablon config: `scripts/nginx/` klasörü (domain’leri değiştirin).

---

## 2) Sunucu `.env` güncellemeleri

### `apps/storefront/.env.local`

```env
MEDUSA_BACKEND_URL=http://127.0.0.1:9000
NEXT_PUBLIC_BASE_URL=https://shop.senindomain.com
NEXT_PUBLIC_DEFAULT_REGION=dk
# publishable key aynı kalır
```

Sonra:

```bash
bash scripts/activate-storefront-standalone.sh
```

### `apps/backend/.env`

Mevcut CORS satırlarına HTTPS domain’leri **ekle** (virgülle):

```env
STORE_CORS=http://localhost:3000,http://localhost:3001,https://shop.senindomain.com
ADMIN_CORS=http://localhost:9000,https://api.senindomain.com
AUTH_CORS=http://localhost:9000,https://api.senindomain.com,https://shop.senindomain.com
```

```bash
pm2 restart medusa-api
```

Admin panel: `https://api.senindomain.com/app`

---

## 3) Güvenlik (önerilir)

- Firewall’da **3001 ve 9000’i dışarı kapat**; trafik sadece 443 (Nginx) üzerinden gelsin.
- Node zaten `127.0.0.1` dinliyorsa dışarıdan port açık olmaz; `0.0.0.0` ise panel proxy yeterli, yine de 443 kullanın.

---

## 4) Kontrol

```bash
curl -sI https://shop.senindomain.com/dk | head -5
curl -sI https://api.senindomain.com/health | head -5
pm2 list
```

Tarayıcıda kilit simgesi + mağaza/checkout çalışmalı.

---

## Sık hatalar

| Belirti | Çözüm |
|---------|--------|
| SSL alınamıyor | DNS A kaydı 5–30 dk bekleyin; domain sunucuya işaret etmeli |
| Mağaza açılıyor API 401/CORS | `STORE_CORS` / `AUTH_CORS` içinde `https://shop...` var mı |
| Mixed content | `NEXT_PUBLIC_BASE_URL` mutlaka `https://` |
| Boş sayfa / 502 | PM2 online mı: `pm2 list`; proxy port 3001/9000 doğru mu |
| aaPanel + PM2 çakışması | Panelde 3001’de ayrı Node site **kapalı** olsun |
