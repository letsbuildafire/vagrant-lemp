# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/centos-7.3'

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
  end

  if Vagrant.has_plugin?('vagrant-omnibus')
    config.omnibus.chef_version = "13.1.31"
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.ssh.forward_agent = true
  config.ssh.insert_key = false

  config.vm.define 'lemp', primary: true do |node|
    node.vm.hostname = 'lemp'
    node.vm.network :private_network, ip: '192.168.167.166'
    node.vm.network :forwarded_port, guest: 3306, host: 3306
    node.vm.synced_folder './www', '/var/www', :owner => 'vagrant', :group => 'root', :mount_options => ['dmode=777', 'fmode=666']
    node.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--memory', 2048]
      vb.customize ['modifyvm', :id, '--cpus', 2]
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
    end
    if Vagrant.has_plugin?('vagrant-hostmanager')
      node.hostmanager.enabled = true
      node.hostmanager.manage_host = true
      node.hostmanager.manage_guest = true
      node.hostmanager.ignore_private_ip = false
      node.hostmanager.include_offline = true
      node.hostmanager.aliases = %w(vagrant.local)
    end
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['chef/cookbooks/']
    chef.data_bags_path = ['chef/data_bags/']
    chef.run_list = ['lemp']
    chef.json = {
      :gpg => {
        data_bag: 'gpg',
        homedir: '/var/www/.gnupg',
        user: 'nginx',
        group: 'nginx'
      },
      :lemp => {
        :server_type => 'dev',
        :vhosts => {
          local: [ 'vagrant.local' ],
        }
      },
      :nginx => {
        default_site_enabled: false,
        port: 80,
        sendfile: 'off',
        default_root: '/var/www',
        listen: 'unix:/var/run/php-fpm-www.sock',
        user: 'nginx',
        group: 'nginx',
      },
      :mysql => {
        port: 3306,
        version: '5.7',
        initial_root_password: 'root',
      },
      :php => {
        package_options: '--enablerepo=remi* --enablerepo=remi-php71',
        packages: [
          'php',
          'php-devel',
          'php-cli',
          'php-pear',
          'php-gd',
          'php-memcached',
          'php-mbstring',
          'php-mysqlnd',
          'php-opcache',
          'php-pdo'
        ],
        directives: {
          'date.timezone': 'UTC'
        }
      },
      :'php-fpm' => {
        listen: '/var/run/php-fpm-www.sock',
        user: 'nginx',
        group: 'nginx'
      },
      :postfix => {
        mail_type: 'master',
        main: {
          mydomain: 'vagrant.local',
          myhostname: 'mail.vagrant.local',
          mydestination: '',
          inet_interfaces: 'all',
          smtp_use_tls: 'no'
        }
      },
    }
  end
end
