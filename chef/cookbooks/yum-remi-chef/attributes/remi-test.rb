default['yum']['remi-test']['repositoryid'] = 'remi'
default['yum']['remi-test']['gpgkey'] = 'http://rpms.remirepo.net/RPM-GPG-KEY-remi'
default['yum']['remi-test']['gpgcheck'] = true
default['yum']['remi-test']['enabled'] = false
default['yum']['remi-test']['managed'] = false

case node['platform']
when 'fedora'
  # default['yum']['remi-test']['baseurl'] = "http://rpms.remirepo.net/fedora/#{node['platform_version'].to_i}/remi-test/$basearch/"
  default['yum']['remi-test']['mirrorlist'] = "http://rpms.remirepo.net/fedora/#{node['platform_version'].to_i}/remi-test/mirror"
  default['yum']['remi-test']['description'] = "Remi's test RPM repository for Fedora Linux #{node['platform_version'].to_i} - $basearch"
when 'amazon'
  # Default to EL6
  # default['yum']['remi-test']['baseurl'] = 'http://rpms.remirepo.net/enterprise/6/remi-test/$basearch/'
  default['yum']['remi-test']['mirrorlist'] = 'http://rpms.remirepo.net/enterprise/6/remi-test/mirror'
  default['yum']['remi-test']['description'] = "Remi's test RPM repository for Enterprise Linux 6 - $basearch"
else
  # default['yum']['remi-test']['baseurl'] = "http://rpms.remirepo.net/enterprise/#{node['platform_version'].to_i}/remi-test/$basearch/"
  default['yum']['remi-test']['mirrorlist'] = "http://rpms.remirepo.net/enterprise/#{node['platform_version'].to_i}/remi-test/mirror"
  default['yum']['remi-test']['description'] = "Remi's test RPM repository for Enterprise Linux #{node['platform_version'].to_i} - $basearch"
end
