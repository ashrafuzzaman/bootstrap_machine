package "git"
package "gitg"

execute "git config name" do
  command "git config --global user.name \"#{node[:git][:user_name]}\""
end

execute "git config email" do
  command "git config --global user.email \"#{node[:git][:email]}\""
end

execute "git diff ui color" do
  command "git config --global color.ui auto"
end