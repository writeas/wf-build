#! /bin/bash

# get url for latest amd 64 linux release
url=`curl -s https://api.github.com/repos/writeas/writefreely/releases/latest | grep 'browser_' | grep 'linux' | grep 'amd64' | cut -d\" -f4`

# create temporary folder
tempdir=`mktemp -d`

# download latest
wget -P $tempdir -q --show-progress $url

# install to /var/www/html
tar -zxvf $tempdir/writefreely_*_linux_amd64.tar.gz -C /var/www
