root = File.absolute_path(File.dirname(__FILE__))
file_cache_path "/tmp/chef-solo"
cookbook_path  %W{#{root}/cookbooks
                  #{root}/site-cookbooks
                  /var/chef/cookbooks}

json_attribs "#{root}/node.json"