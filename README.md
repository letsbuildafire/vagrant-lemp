vagrant-centos-chef-lemp
========================

A lemp stack provisioned with Chef on Centos 7.3 with nginx, php-7.1, php-fpm, mysql 5.7, postfix.

Install
=======

#### 1. [Install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
a [Install VirtualBox Extension Pack](http://download.virtualbox.org/virtualbox/5.1.22/Oracle_VM_VirtualBox_Extension_Pack-5.1.22-115126.vbox-extpack)


#### 2. [Install Vagrant](https://www.vagrantup.com/downloads.html)


#### 3. Install the necessary plugins for Vagrant
```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-hostmanager
```

#### 4. Optionally, install a cache plugin for Vagrant
> vagrant-cachier caches rpms once already fetched to speed up re-provisioning.
```
vagrant plugin install vagrant-cachier
```

#### 5. Clone the lemp-vm repository
```
mkdir <directory> && cd "$_"
git clone https://bitbucket.org/letsbuildafire/vagrant-lemp.git .
```


#### 6. Start the virtual machine and provision it with Vagrant and Chef Solo
```
vagrant up --provision
```


#### A. Connect to database in Sequel Pro
To connect directly to the database, create a new SSH connection in Sequel Pro with the following settings.

Option           |   Value
-----------------|-------------
mysql host       |   lemp
mysql username   |   root
mysql password   |   root
ssh host         |   lemp
ssh username     |   vagrant
ssh password     |   vagrant
