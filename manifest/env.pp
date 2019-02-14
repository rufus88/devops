#Rafael E Rumbos S

#create the update deploy application
file { '/home/admin/scripts/git_updater_app.sh':
  ensure => present,
  content => "#!/bin/bash
  cd /home/admin/deploy
if [[ `git status --untracked-files=no --porcelain` ]]; then
  git pull
  cd /home/admin/deploy/application-master && /usr/local/n/versions/node/9.11.1/bin/npm install && /usr/local/n/versions/node/9.11.1/bin/npm start
fi",
  mode     => '0774',
  owner    => 'admin',
  group    => 'admin',
}


#Set a cronjob for refreshing the application
cron { 'app_update_checker':
  command => '/home/admin/scripts/git_updater_app.sh',
  hour => '*',
  minute => '*/6',
}
############END APPLICATION




#update run puppet scripts
file { '/etc/puppet/code/environments/production/scripts/puppet-checker.sh':
  ensure => present,
  content => "#!/bin/bash
cd /etc/puppet/code/environments/production
if [[ `git status --untracked-files=no --porcelain` ]]; then
  git pull
  puppet apply /etc/puppet/code/environments/production/manifest/env.pp
fi",
  mode     => '0774',
  owner    => 'admin',
  group    => 'admin',
}


#Set a cronjob for refreshing the manifest
cron { 'manifest_checker':
  command => '/etc/puppet/code/environments/production/scripts/puppet-checker.sh',
  hour => '*',
  minute => '*/6',
}
############END PUPPET
