#!/bin/bash -eux

wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org=4.2.18 mongodb-org-server=4.2.18 mongodb-org-shell=4.2.18 mongodb-org-mongos=4.2.18 mongodb-org-tools=4.2.18
privatednsname=$(curl http://169.254.169.254/latest/meta-data/hostname)
sudo sed -i "s,\\(^[[:blank:]]*bindIp:\\) .*,\\1 $privatednsname," /etc/mongod.conf
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
mkdir ~/download
wget http://media.mongodb.org/zips.json -P ~/download
mongoimport --host $privatednsname:27017 --db testdb --collection zips --file ~/download/zips.json