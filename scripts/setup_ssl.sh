#!/bin/sh

# 証明書がすでに存在するか確認
if [ ! -f "/etc/letsencrypt/live/oshitetsu.com/fullchain.pem" ]; then
    echo "🔐 Let's Encrypt SSL 証明書を取得中..."
    certbot certonly --webroot -w /var/www/railway_app -d oshitetsu.com --non-interactive --agree-tos -m admin@oshitetsu.com
else
    echo "✅ SSL 証明書はすでに存在します"
fi

# Docker コンテナの Nginx をリロード
docker exec nginx-container nginx -s reload

