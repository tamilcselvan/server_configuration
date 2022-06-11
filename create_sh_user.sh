#!/bin/sh
read -p "Please enter your site name  : " sitename
read -p "Please enter your username  : " username
sudo mkdir -p /home/${sitename}/
sudo adduser --home /home/${sitename}/ --shell /bin/bash --no-create-home --ingroup www-data --ingroup ssh ${username}
sudo groupadd ${username}
sudo usermod -a -G www-data ${username}
sudo usermod -a -G ${username} ${username}
sudo chmod g+s /home/${username}/
sudo chown -R ${username}:${username} .

echo "${username}" | sudo tee -a /etc/vsftpd.userlist
sudo systemctl restart vsftpd