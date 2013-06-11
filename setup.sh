#!/bin/bash

sudo apt-get -y install aptitude git tar
# Install Ruby and Chef

if ! type ruby > /dev/null; then
  echo -e "\e[32m Installing ruby"
  sudo aptitude install -y ruby1.9.3 ruby1.9.3-dev make
else
  echo -e "\e[32mRuby already installed"
fi
echo -e '\e[00m'

if ! type chef-solo > /dev/null; then
  echo -e "\e[32mInstalling chef..."
  sudo gem install --no-rdoc --no-ri chef
else
  echo -e "\e[32mChef already installed"
fi

echo -e "\e[33mCloning recipies"
cd site-cookbooks
books=(mysql openssl build-essential runit ohai apt yum mongodb)
for book in "${books[@]}"
do
  if [ ! -d $book ]; then
    knife cookbook site download $book && tar -xvf $book-*.tar.gz && rm $book-*.tar.gz
  else
    echo -e "\e[32m$book already installed"
  fi
done
echo -e '\e[00m'
# sudo rm -rf /etc/chef/ohai_plugins/README