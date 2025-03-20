#!/bin/bash

# package install
sudo yum update -y
sudo yum -y install gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel libffi-devel libxml2 libxslt libxml2-devel libxslt-devel sqlite-devel

# install rbenv
if ! command -v rbenv &> /dev/null; then
  mkdir -p ~/.rbenv
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  # shellcheck disable=SC2016
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  # shellcheck disable=SC2016
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile
fi

# install ruby
RUBY_BUILD_BUILD_OPTS=--verbose rbenv install 3.2.2
rbenv global 3.2.2

# uninstall rvm
if command -v rvm &> /dev/null; then
  rvm seppuku --force
  source ~/.bash_profile
fi

# install rails
printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri\n" >> ~/.gemrc
gem install rails -v 7.0.4

# uninstall MariaDB, install MySQL 5.7
sudo service mariadb stop
sudo yum -y erase mariadb-*
sudo yum -y localinstall https://repo.mysql.com/mysql80-community-release-el7-5.noarch.rpm
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum -y install mysql-community-server mysql-community-devel
sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service

DB_PASSWORD=$(sudo grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
mysql -u root -p${DB_PASSWORD} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'TB@shibuya1';uninstall plugin validate_password;set password for root@localhost=password('');"

# install docker-compose
#sudo mkdir -p /usr/local/lib/docker/cli-plugins
#sudo curl -L https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
#sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
#sudo ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# yarn install
#curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
#sudo yum install yarn

# node version
nvm install 16.0.0
nvm use 16.0.0
nvm alias default v16.0.0
