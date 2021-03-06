require 'chef/provider/lwrp_base'
require 'shellwords'

class Chef
  class Provider
    class MysqlService
      class Debian < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'debian pattern' do
            ##################
            prefix_dir = '/usr'
            run_dir = '/var/run/mysqld'
            pid_file = '/var/run/mysqld/mysql.pid'
            socket_file = '/var/run/mysqld/mysqld.sock'
            include_dir = '/etc/mysql/conf.d'
            ##################

            package 'debconf-utils' do
              action :install
            end

            directory '/var/cache/local/preseeding' do
              owner 'root'
              group 'root'
              mode '0755'
              action :create
              recursive true
            end

            template '/var/cache/local/preseeding/mysql-server.seed' do
              cookbook 'mysql'
              source 'debian/mysql-server.seed.erb'
              owner 'root'
              group 'root'
              mode '0600'
              action :create
              notifies :run, 'execute[preseed mysql-server]', :immediately
            end

            execute 'preseed mysql-server' do
              command '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
              action :nothing
            end

            # package automatically initializes database and starts service.
            # ... because that's totally super convenient.
            package 'mysql-server' do
              action :install
            end

            # service
            service 'mysql' do
              provider Chef::Provider::Service::Init::Debian
              supports :restart => true
              action [:start, :enable]
            end

            execute 'assign-root-password' do
              cmd = "#{prefix_dir}/bin/mysqladmin"
              cmd << ' -u root password '
              cmd << Shellwords.escape(new_resource.server_root_password)
              command cmd
              action :run
              only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
            end

            template '/etc/mysql_grants.sql' do
              cookbook 'mysql'
              source 'grants/grants.sql.erb'
              owner 'root'
              group 'root'
              mode '0600'
              variables(:config => new_resource)
              action :create
              notifies :run, 'execute[install-grants]'
            end

            if new_resource.server_root_password.empty?
              pass_string = ''
            else
              pass_string = '-p' + Shellwords.escape(new_resource.server_root_password)
            end

            execute 'install-grants' do
              cmd = "#{prefix_dir}/bin/mysql"
              cmd << ' -u root '
              cmd << "#{pass_string} < /etc/mysql_grants.sql"
              command cmd
              action :nothing
            end

            template '/etc/mysql/debian.cnf' do
              cookbook 'mysql'
              source 'debian/debian.cnf.erb'
              owner 'root'
              group 'root'
              mode '0600'
              action :create
            end

            #
            directory include_dir do
              owner 'mysql'
              group 'mysql'
              mode '0750'
              recursive true
              action :create
            end

            directory run_dir do
              owner 'mysql'
              group 'mysql'
              mode '0755'
              action :create
              recursive true
            end

            directory new_resource.data_dir do
              owner 'mysql'
              group 'mysql'
              mode '0750'
              recursive true
              action :create
            end

            template '/etc/mysql/my.cnf' do
              if new_resource.template_source.nil?
                source "#{new_resource.version}/my.cnf.erb"
                cookbook 'mysql'
              else
                source new_resource.template_source
              end
              owner 'mysql'
              group 'mysql'
              mode '0600'
              variables(
                :data_dir => new_resource.data_dir,
                :pid_file => pid_file,
                :socket_file => socket_file,
                :port => new_resource.port,
                :include_dir => include_dir
                )
              action :create
              notifies :run, 'bash[move mysql data to datadir]'
              notifies :restart, 'service[mysql]'
            end

            bash 'move mysql data to datadir' do
              user 'root'
              code <<-EOH
              service mysql stop \
              && mv /var/lib/mysql/* #{new_resource.data_dir}
              EOH
              action :nothing
              only_if "[ '/var/lib/mysql' != #{new_resource.data_dir} ]"
              only_if "[ `stat -c %h #{new_resource.data_dir}` -eq 2 ]"
              not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
            end
          end
        end

        action :restart do
          converge_by 'debian pattern' do
            service 'mysql' do
              provider Chef::Provider::Service::Init::Debian
              supports :restart => true
              action :restart
            end
          end
        end

        action :reload do
          converge_by 'debian pattern' do
            service 'mysql' do
              provider Chef::Provider::Service::Init::Debian
              action :reload
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :debian, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Debian
