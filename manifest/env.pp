#Rafael E Rumbos S

# Install links
package { 'links2':
  ensure => installed,
}



# Install git
package { 'git':
  ensure => installed,
}

#Instalamos apache2
package { 'apache2':
  ensure => installed,
}

#create the virtualhost for apache
file { '/etc/apache2/sites-available/000-default.conf':
  ensure => file,
  content => "LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
<VirtualHost *:80>
ProxyPreserveHost On
ProxyRequests Off
ServerName myhost.com
ServerAlias ww.myhost.com
ProxyPass / http://localhost:3000/
ProxyPassReverse / http://localhost:3000/
</VirtualHost>",
require => Package['apache2'],
}

#Restart apache2
service { 'apache2':
  ensure => running,
  enable => true,
  hasrestart => true,
}


#create the nodejs script
file { '/etc/puppet/code/environments/production/scripts/nodejs.sh':
  ensure => present,
  content => "sudo curl -sL https://deb.nodesource.com/setup_10.x | bash -
sudo aptitude install -y nodejs
sudo npm cache clean -f
sudo npm install -g n
sudo n 9.11.1",
  mode     => '0755',
  owner    => 'root',
  group    => 'root',

}


exec { 'Generate the config':
  command  => '/etc/puppet/code/environments/production/scripts/nodejs.sh',
  cwd      => '/etc/puppet/code/environments/production/scripts',
  user     => 'root',
}


####DOWNLOAD AND DEPLOY the application
#create the deploy script
file { '/home/admin/scripts/deploy.sh':
  ensure => present,
  content => "#!/bin/bash
killall node
rm -r /home/admin/deploy
cd /home/admin/ && git clone https://github.com/rufus88/deploy.git
cd /home/admin/deploy/application-master && /usr/local/n/versions/node/9.11.1/bin/npm install && /usr/local/n/versions/node/9.11.1/bin/npm start",
  mode     => '0774',
  owner    => 'admin',
  group    => 'admin',

}


exec { 'deploy_the_app':
  command  => '/home/admin/scripts/deploy.sh',
  cwd      => '/home/admin/scripts',
  user     => 'admin',
}


#create the update deploy application
file { '/home/admin/scripts/git_updater_app.sh':
  ensure => present,
  content => "#!/bin/bash
  cd /home/admin/deploy
if [[ `git status --untracked-files=no --porcelain` ]]; then
  git pull
  cd /home/admin/deploy/application-master && /usr/local/n/versions/node/9.11.1/bin/npm install && /usr/local/n/versions/node/9.11.1/bin/npm start
else
fi",
  mode     => '0774',
  owner    => 'admin',
  group    => 'admin',
}


#Set a cronjob for refreshing the application
cron { 'app_update_checker':
  command => '/home/admin/scripts/git_updater_app.sh',
  hour => '*',
  minute => '*/5',
}
############END APPLICATION

#update run puppet scripts
file { '/etc/puppet/code/environments/production/scripts/puppet-checker.sh':
  ensure => present,
  content => "#!/bin/bash
cd /etc/puppet/code/environments/production
if [[ `git status --untracked-files=no --porcelain` ]]; then
  git pull
  puppet apply /etc/puppet/code/environments/production/manifest
else
fi",
  mode     => '0774',
  owner    => 'admin',
  group    => 'admin',
}


#Set a cronjob for refreshing the manifest
cron { 'manifest_checker':
  command => '/etc/puppet/code/environments/production/scripts',
  hour => '*',
  minute => '*/5',
}
############END PUPPET
