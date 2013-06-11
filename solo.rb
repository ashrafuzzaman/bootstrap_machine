root = File.absolute_path(File.dirname(__FILE__))
file_cache_path "/tmp/chef-solo"
cookbook_path  %W{#{root}/cookbooks
                  /var/chef/cookbooks}