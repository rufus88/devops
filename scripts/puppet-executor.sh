#!/bin/bash
cd /etc/puppet/code/environments/production && git pull
/usr/bin/puppet apply /etc/puppet/code/environments/production/manifest/
