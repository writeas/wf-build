#! /bin/bash

# generate random password string 32 characters in length

root_db_pass=`date +%s | sha256sum | base64 | head -c 32 ; echo`

# generate random pass for user
pass=`date +%s | sha256sum | base64 | head -c 32 ; echo`

# save to disk
printf '%s' $root_db_pass > /var/www/writefreely/.root.db.pass
printf '%s' $pass > /var/www/writefreely/.user.db.pass

# set the root password
mysqladmin password "$root_db_pass"

# create writefreely database and user with privileges
mariadb -u root -p$root_db_pass -e "CREATE DATABASE writefreely;"
mariadb -u root -p$root_db_pass -e "GRANT ALL PRIVILEGES ON writefreely.* TO writefreely@'localhost' IDENTIFIED BY '$pass';"

# flush privileges

mariadb -u root -p$root_db_pass -e "FLUSH PRIVILEGES;"

# replace db password placeholder
sed -i "s/password = PASSWORD/password = $pass/g" /var/www/writefreely/config.ini

