#!/bin/sh

# Install chef solo
curl -L https://www.opscode.com/chef/install.sh | bash

#sudo add-apt-repository ppa:brightbox/ruby-ng-experimental
#sudo apt-get update
#sudo apt-get install -y ruby2.0

sudo chef-solo -c solo.rb -j node.json