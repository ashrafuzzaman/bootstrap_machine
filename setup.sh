#!/bin/bash

sudo apt-get -y install aptitude git tar &&
# Install Ruby and Chef

echo "Installing ruby and chef..."
sudo aptitude install -y ruby1.9.3 ruby1.9.3-dev make &&
sudo gem install --no-rdoc --no-ri chef

echo "Cloning recipies"
cd site-cookbooks
books=(mysql openssl build-essential runit ohai apt yum mongodb)
for book in "${books[@]}"
do
  if [ ! -d $book ]; then
    knife cookbook site download $book && tar -xvf $book-*.tar.gz && rm $book-*.tar.gz
  fi
done

# sudo rm -rf /etc/chef/ohai_plugins/README