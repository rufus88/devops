#Rafael E Rumbos S

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

# Install unzip
package { 'unzip':
  ensure => installed,
}


# Install git
package { 'git':
  ensure => installed,
}



# El servicio debe estar arriba
#service { 'sshd':
#  ensure => running,
#  enable  => true,
#}


#Instalamos apache2
package { 'cowsay':
  ensure => installed,
}


#Instalamos apache2
package { 'typespeed':
  ensure => installed,
}


#Set a cronjob for refreshing the manifest
cron { run-puppet':
  command => /usr/local/bin/puppetrun,
  hour => '*',
  minute: '*/10',
}
