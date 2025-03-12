FROM ruby:3.3.0

# yarn install
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev nodejs npm vim default-mysql-client && \
    npm install n -g && \
    n 16.0.0 && \
    gem install rails

# ffmpeg install
RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y ffmpeg libvips

WORKDIR /src

ADD ./Gemfile /src/Gemfile
ADD ./Gemfile.lock /src/Gemfile.lock
RUN bundle install

# アプリケーションの起動コマンド
CMD ["sh", "-c", "rm -f tmp/pids/unicorn.pid && exec bundle exec unicorn -c config/unicorn.rb -E production"]