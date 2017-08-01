#
# Cookbook:: lemp
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'selinux'
include_recipe 'postfix'
include_recipe 'chef_nginx'
include_recipe 'memcached'
include_recipe 'yum-mysql-community::mysql57'
include_recipe 'yum-remi-chef::remi'
include_recipe 'yum-remi-chef::remi-php71'
include_recipe 'php'

# remove all currently installed keys and configuration
directory node['gpg']['homedir'] do
  owner node['gpg']['user']
  group node['gpg']['group']
  mode 00700
  recursive true
  action [:delete, :create]
end

# create the gpg.conf
template 'gpg-configuration' do
  path "#{node['gpg']['homedir']}/gpg.conf"
  source 'default.gpg.erb'
  owner node['gpg']['user']
  group node['gpg']['group']
  mode 00600
  variables(
    :homedir => node['gpg']['homedir']
  )
  action :create
end

# import the public gpg keys
# TODO: they should be encrypted data bags
gpg_keys = data_bag(node['gpg']['data_bag'])
gpg_keys.each do |gpg_key|

  filename = (0...16).map { (65 + rand(26)).chr }.join
  key = data_bag_item(node['gpg']['data_bag'], gpg_key)

  # create a temp file to store the key in
  file "/tmp/#{filename}.asc" do
    content key['key']
    owner node['gpg']['user']
    mode 00700
    sensitive true
    action :create
  end

  # import the key, we have to disable locking for now
  # because we have the folder mapped and linked folders
  # cannot be locked
  execute "gpg --import #{gpg_key}" do
    command "/usr/bin/gpg --lock-never --homedir #{node['gpg']['homedir']} --import /tmp/#{filename}.asc"
    user node['gpg']['user']
  end

  # remove the temporary file
  file "/tmp/#{filename}.asc" do
    action :delete
  end

end

# we will assume that the keys that we have imported can be trusted, so
# lets add them all to the trustdb
execute "gpg --import-ownertrust" do
  command "gpg --homedir #{node['gpg']['homedir']} --list-keys --with-fingerprint --with-colons | sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\\1:6:/p' | gpg --homedir #{node['gpg']['homedir']} --import-ownertrust"
  user node['gpg']['user']
end

# apply the correct permissions to our nginx cache directories
%w[ /var/cache/nginx /var/cache/nginx/tmp ].each do |path|
  directory path do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode 00770
    recursive true
    action :create
  end
end

# apply the correct permissions to our php temp and session directories
%w[ /var/cache/fastcgi/tmp /var/lib/php/session ].each do |path|
  directory path do
    owner node['php-fpm']['user']
    group node['php-fpm']['group']
    mode 00770
    recursive true
    action :create
  end
end

# create the mysql server
mysql_service 'lmno' do
  port node['mysql']['port']
  version node['mysql']['version']
  initial_root_password node['mysql']['initial_root_password']
  action [:create, :start]
end

# configure the mysql server
mysql_config 'lmno' do
  instance 'lmno'
  source 'default.mysql.erb'
  notifies :restart, 'mysql_service[lmno]'
  action :create
end

# create the vhost configuration files for each set of vhosts
node['lemp']['vhosts'].each do |vhost_group, vhosts|

  root_without_vhost = "#{node['nginx']['default_root']}/#{vhost_group}"

  # apply the correct permissions to our web directories
  execute "chmod -R 755 #{root_without_vhost}" do
    command "chmod -R 755 #{root_without_vhost}"
  end
  # apply the correct permissions to all of the files within the web directories
  execute "chmod -R 644 #{root_without_vhost}" do
    command "find #{root_without_vhost} -type f -exec chmod 644 -- {} +"
  end

  # apply the correct ownership to our web directories
  execute "chown -R #{root_without_vhost}" do
    command "chown -R #{node['nginx']['user']}:#{node['nginx']['group']} #{root_without_vhost}"
  end

  vhosts.each do |vhost|

    root = "#{root_without_vhost}/#{vhost}"

    template 'default' do
      path "/etc/nginx/sites-available/#{vhost}"
      source 'default.nginx.erb'
      owner node['nginx']['user']
      group node['nginx']['group']
      mode 00644
      variables(
        :root_without_vhost => root_without_vhost,
        :root => root,
        :vhost => vhost
      )
      action :create
    end

    link "/etc/nginx/sites-enabled/#{vhost}" do
        to "/etc/nginx/sites-available/#{vhost}"
        notifies :reload, 'service[nginx]', :delayed
    end

  end

end

# configure php-fpm
php_fpm_pool 'www' do
  listen node['php-fpm']['listen']
  user node['php-fpm']['user']
  group node['php-fpm']['group']
  listen_user node['php-fpm']['user']
  listen_group node['php-fpm']['group']
  action :install
end

