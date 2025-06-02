#!/bin/bash

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt update -y
sudo apt install -y nodejs postgresql
cd home/ubuntu
sudo -u ubuntu git clone https://github.com/Ninexis/app-arcl-back.git

echo "DATABASE_URI=postgresql://arcl_user:password@localhost:5432/arcl" > /home/ubuntu/app-arcl-back/.env
echo "PORT=5000" >> /home/ubuntu/app-arcl-back/.env
cd app-arcl-back
sudo -u ubuntu npm install
sudo usermod -aG ubuntu postgres
sudo -u postgres psql -c "CREATE DATABASE arcl;"
sudo -u postgres psql -c "CREATE USER arcl_user WITH PASSWORD 'password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE arcl TO arcl_user;"
sudo -u postgres psql -c "ALTER USER arcl_user WITH SUPERUSER;"
sudo -u postgres psql -d arcl -f /home/ubuntu/app-arcl-back/init.sql
sudo npm install -g pm2
sudo -u ubuntu pm2 start /home/ubuntu/app-arcl-back/src/server.js --name arcl-backend
cd ..
sudo -u ubuntu pm2 save
sudo -u ubuntu pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
