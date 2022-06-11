#!/bin/sh

sitename=$1

#generate a random password including special characters
password=$(cat /dev/urandom | tr -dc '_#$%&()a-zA-Z0-9' | fold -w 21 | head -n 1)

# generate user from sitename for example "example.com"
user=$(echo $sitename | tr '[:upper:]' '[:lower:]' | cut -d. -f1)
group=$(echo $sitename | tr '[:upper:]' '[:lower:]' | cut -d. -f1)

# create user and group and assign to www-data and home directory
useradd -m -g $group -s /bin/bash $user

# assign to www-data
usermod -a -G www-data $user
usermod -a -G ssh $user

# assign to home directory
chown -R $user:$group /home/$user

# assign permissions
chmod -R 755 /home/$user

# set password
echo "$user:$password" | chpasswd

# create home directory
mkdir /home/$user

# create public_html directory
mkdir /home/$user/public_html

mkdir /home/$user/backups

mkdir /home/$user/logs