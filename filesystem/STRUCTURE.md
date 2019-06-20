# Filesystem folder structure

### /etc/nginx/sites-available

**`writefreely`**: the NGINX server block for the instance, with a placeholder for the server name, replaced on first run.

### /etc/systemd/system

**`writefreely.service`**: a systemd service unit for the writefreely instance.

### /etc/update-motd.d

**`99-writefreely`**: script to display a custom message of the day shown to users on log in via SSH.

Includes some links and quick reference info about the instance.

### /opt/writefreely

**`first_run.sh`**: an interactive script the takes the user through the initial configuration of the new instance.

It does a bit of search and replace in configuration files after getting input from the user.

It also runs `certbot --nginx` and `writefreely -config`, before enabling and starting up the systemd service.

### /var/lib/cloud/scripts/per-instance

These scripts are run in sequential order when a new VPS is provisioned using the base snapshot.

**`00-install-writefreely.sh`**: downloads the latest release from GitHub and extracts it to `/var/www/html`.

**`10-database.sh`**: generates random passwords for the database root user and writefreely user.

Both passwords are stored on disk under `/var/www/html/.root.db.pass` and `/var/www/html/.user.db.pass` respectively.

It then sets the root password, creates a writefreely database and user with the generated password. Then updates the `/var/www/html/config.ini` with the correct credential.

### /var/www/writefreely

**`config.ini`**: is a base writefreely configuration file with some placeholders for the scripts to manipulate before running `writefreely -config` on first run.