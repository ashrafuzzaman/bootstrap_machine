# apt_repository "sublime-text-2" do
#   uri "http://ppa.launchpad.net/webupd8team/sublime-text-2/ubuntu"
#   components ["main"]
#   distribution node['lsb']['codename']
#   keyserver 'keyserver.ubuntu.com'
#   key "1024R/EEA14886"
#   deb_src true

#   #notifies :run, resources(:execute => "apt-get update"), :immediately
# end

execute "add sublime text repo" do
  command "sudo add-apt-repository ppa:webupd8team/sublime-text-2"
end

execute "update apt" do
  command "sudo apt-get update"
end

package "sublime-text"