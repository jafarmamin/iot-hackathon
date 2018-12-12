#!/bin/bash


# Install some packages
sudo yum -y install postgresql-server postgresql-contrib git

#Clone Repo
sudo git clone https://github.com/horsch37/iot-hackathon /opt/demo

# Source some shared variables
sudo . /opt/demo/shared.sh

# Setup hostname

sudo sed -i "s/localhost4.localdomain4/localhost4.localdomain4 $HOSTNAME/g" /etc/hosts
sudo hostnamectl set-hostname $HOSTNAME

# Install some packages

sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Setup Postgres Users

sudo -u postgres createuser druid;
sudo -u postgres psql -c "alter user druid with password 'druid'";
sudo -u postgres psql -c "create database druid owner druid;"
sudo -u postgres psql -c "grant all privileges on database druid to druid";

sudo -u postgres createuser hive;
sudo -u postgres psql -c "alter user hive with password 'hive'";
sudo -u postgres psql -c "create database hive owner hive;"
sudo -u postgres psql -c "grant all privileges on database hive to hive";

sudo sed -i "s/\(127.0.0.1\/32\s\+\)ident/\1trust/g" /var/lib/pgsql/data/pg_hba.conf 
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
sudo echo 'host    all          all            0.0.0.0/0  trust' | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
sudo systemctl restart postgresql
