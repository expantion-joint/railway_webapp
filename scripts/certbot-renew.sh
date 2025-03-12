#!/bin/sh

echo "🔄 Let's Encrypt 証明書の更新を開始します..."

# 証明書を更新
certbot renew --non-interactive --quiet

# Nginx をリロードして新しい証明書を適用
docker exec nginx_proxy nginx -s reload

echo "✅ 証明書の更新が完了しました。"
