execute "apt_update" do
  command "apt-get update"
  action :run
end

package "mongodb-10gen"