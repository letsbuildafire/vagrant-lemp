name 'lemp'
maintainer 'Dakoda'
maintainer_email 'dakoda@meetlmno.com'
license 'All Rights Reserved'
description 'Installs/Configures a LEMP stack'
version '0.1.3'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'chef_nginx'
depends 'memcached'
depends 'php'
depends 'postfix'
depends 'selinux'
depends 'yum-mysql-community'
depends 'yum-remi-chef'
