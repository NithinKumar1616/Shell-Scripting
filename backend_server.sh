#! /bin/bash

set -x

set -e

set -o

cd /home/ec2-user || exit

sudo dnf module disable nodejs -y
$?

sudo dnf module enable nodejs:20 -y
$?

sudo dnf install nodejs -y
$?

#Add application User

sudo useradd expense || echo "User 'expense' has been added successfully"
$?

#We keep application in one standard location. This is a usual practice that runs in the organization.

#Lets setup an app directory.

sudo mkdir /app
$?

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

sudo rm -rf /app/*

sudo unzip /tmp/backend.zip

sudo npm install

#We need to setup a new service in systemd so systemctl can manage this service

# Create the backend.service file programmatically

sudo bash -c 'cat <<EOF > /etc/systemd/system/backend.service
[Unit]
Description=Backend Service

[Service]
User=expense
Environment=DB_HOST="database-server.nithinlearning.site"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend

[Install]
WantedBy=multi-user.target
EOF'

$?

sudo dnf install mysql -y
$?

sudo mysql -h database-server.nithinlearning.site -uroot -pExpenseApp@1 < /app/schema/backend.sql
$?

sudo systemctl daemon-reload

sudo systemctl enable backend

sudo systemctl restart backend

#For this application to work fully functional we need to load schema to the Database.

#We need to load the schema. To load schema we need to install mysql client.

#To have it installed we can use

