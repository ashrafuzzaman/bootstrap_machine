# gem_package "bundler"

# #dependecies for nokogiri
# package "libxml2-dev"
# package "libxslt1-dev"

# #dependecies for rmagic
# package "imagemagick"
# package "libmagickwand-dev"
# package "wget"

execute "git config name" do
  command "git config --global user.name \"#{node[:git][:user_name]}\""
end

execute "git config email" do
  command "git config --global user.email \"#{node[:git][:email]}\""
end

# execute "install google chrome" do
#   command "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo dpkg -i google-chrome-stable_current_amd64.deb"
# end

# execute "apt-get update" do
#   command "apt-get update"
# end

# package "google-chrome-stable"
# wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb