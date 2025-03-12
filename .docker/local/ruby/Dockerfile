FROM ruby:3.3.0

# yarn install
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# docker-compose.yml から渡された環境変数を ENV に設定
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV}

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev nodejs npm vim default-mysql-client && \
    npm install n -g && \
    n 16.0.0 && \
    gem install rails

# ffmpeg install
RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y ffmpeg libvips

# https化 Let's Encrypt 
RUN apt-get update && \
    apt-get install -y certbot python3-certbot-nginx

WORKDIR /src

ADD ./Gemfile /src/Gemfile
ADD ./Gemfile.lock /src/Gemfile.lock
RUN bundle install

# **production の場合のみ SSL 設定を追加**
RUN if [ "$RAILS_ENV" = "production" ]; then \
    echo "SSL 証明書の設定を開始..."; \
    COPY ./scripts/setup_ssl.sh /setup_ssl.sh; \
    COPY ./scripts/certbot-renew.sh /certbot-renew.sh; \
    chmod +x /setup_ssl.sh /certbot-renew.sh; \
    echo "0 3 * * * root /certbot-renew.sh >> /var/log/certbot-renew.log 2>&1" > /etc/cron.d/certbot-renew; \
    chmod 0644 /etc/cron.d/certbot-renew; \
    crontab /etc/cron.d/certbot-renew; \
  fi

# アプリケーションの起動コマンド
CMD ["sh", "-c", "if [ \"$RAILS_ENV\" = \"production\" ]; then /setup_ssl.sh; fi && rm -f tmp/pids/unicorn.pid && exec bundle exec unicorn -c config/unicorn.rb -E production"]