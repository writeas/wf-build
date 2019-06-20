#! /bin/bash

bold=`tput bold`
dim=`tput dim`
undr=`tput smul`
norm=`tput sgr0`

warn=`tput setaf 3`
good=`tput setaf 10`
blue=`tput setaf 12`

# get machine ip
ip=`dig +short myip.opendns.com @resolver1.opendns.com`

# warn user about DNS
printf "\n${bold}${blue}Welcome to the writefreely one-click setup wizard.${norm}\n"
printf "This script will guide you through configuring your new instance.\n\n"
printf "\t${warn}${bold}Before you continue, please point your domain at ${undr}$ip${norm}\n"

# pause, confirm or exit
printf "\n${warn}DNS changes can take a while to propagate, to check the status you could ping${norm}\n"
printf "${warn}your domain name. ${norm}${dim}i.e. 'ping duckduckgo.com'${norm}\n"
read -p "When you are ready, press ${good}[ENTER]${norm} to continue."

# required for weird journald issue
# no journal files are found until an initial restart of the service
systemctl restart systemd-journald

# get domain name
printf "\nPlease enter the domain name that points at this instance.\n${dim}i.e. dev.write.as${norm}\n"
read -p "https://" domain

# edit nginx config
sed -i "s/server_name SERVERNAME;/server_name $domain;/g" /etc/nginx/sites-available/writefreely

# reload nginx
printf "\n${bold}NGINX config updated.${norm}\n"
printf "${warn}${bold}Reloading...${norm}\n"
systemctl restart nginx
printf "\n${good}${bold}Done.${norm}\n"

# edit config.ini
sed -i "s/host              = HOSTNAME/host              = https:\/\/$domain/g" /var/www/writefreely/config.ini

# run certbot
printf "\nNext we will set up certificates with Let's Encrypt\n"
certbot --nginx

printf "\nNext you will be guided through the writefreely configuration.\n\n"
printf "Choose ${good}'Production, behind reverse proxy'${norm}.\n"
printf "Then use the defaults provided until you reach the 'App setup' section.\n"
printf "Where you will enter in your own details where missing...\n"
printf "\n\t${warn}Securely store your admin username and password.${norm}\n"
printf "\t${warn}If you forget, follow the instructions here:${norm}\n"
printf "\t${warn}https://writefreely.org/docs/latest/admin/commands.md${norm}\n\n"
read -p "Again, press ${good}[ENTER]${norm} when ready to continue..."

# run writefreely config from dir
cd /var/www/writefreely
./writefreely --config

# generate encryption keys
./writefreely --gen-keys

printf "\n${bold}Done.${norm}\n"
printf "\n${warn}${bold}Starting writefreely...${norm}\n"

chown -R writefreely:www-data /var/www/writefreely

# enable and start writefreely
systemctl enable writefreely.service
systemctl start writefreely.service

printf "\n${good}${bold}Done.${norm}\n"
printf "\n${bold}Visit https://$domain in a browser to log in.${norm}\n"

cp -f /etc/skel/.bashrc /root/.bashrc
