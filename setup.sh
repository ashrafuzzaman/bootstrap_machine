#!/bin/bash

# Store the base dir
BASEDIR=$( cd $(dirname $0); pwd)

# sudo apt-get update && sudo apt-get dist-upgrade
sudo apt-get -y install aptitude git tar
if ! type ruby > /dev/null; then
  echo -e "\e[32m Installing ruby\e[00m"
  sudo aptitude install -y ruby1.9.3 ruby1.9.3-dev make
else
  echo -e "\e[32mRuby already installed\e[00m"
fi

if ! type chef-solo > /dev/null; then
  echo -e "\e[32mInstalling chef...\e[00m"
  sudo gem install --no-rdoc --no-ri chef
else
  echo -e "\e[32mChef already installed\e[00m"
fi

echo -e "\e[33mCloning recipies\e[00m"
sudo mkdir -p /var/chef/cookbooks
cd /var/chef/cookbooks

books=(mysql openssl build-essential runit ohai apt yum mongodb postgresql java windows chef_handler)
for book in "${books[@]}"
do
  if [ ! -d $book ]; then
    sudo knife cookbook site download $book && sudo tar -xvf $book-*.tar.gz && sudo rm $book-*.tar.gz
  else
    echo -e "\e[32m$book already installed\e[00m"
  fi
done

if [ ! -d rvm ]; then
sudo curl -Ls https://github.com/fnichol/chef-rvm/tarball/v0.9.0 | sudo tar xfz - && \
  sudo mv fnichol-chef-rvm-* rvm
fi
# sudo rm -rf /etc/chef/ohai_plugins/README

cd $BASEDIR && sudo chef-solo -c solo.rb -j node.json