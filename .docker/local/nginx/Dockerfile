FROM nginx:latest

# Certbot のインストール
RUN apt update && apt install -y certbot python3-certbot-nginx

# Nginx の設定を追加
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# 証明書用ディレクトリを作成
RUN mkdir -p /var/www/html/.well-known/acme-challenge/
