#! /bin/bash

set -x

set -e

set -o

cd /home/ec2-user || exit

sudo dnf module disable nodejs -y

sudo dnf module enable nodejs:20 -y

sudo dnf install nodejs -y

#Add application User

sudo useradd -m expense || echo "User 'expense' already exists"

#We keep application in one standard location. This is a usual practice that runs in the organization.

#Lets setup an app directory.

sudo mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

sudo unzip /tmp/backend.zip

sudo npm install

#We need to setup a new service in systemd so systemctl can manage this service

vim /etc/systemd/system/backend.service

[Unit]
Description = Backend Service

[Service]
User=expense
Environment=DB_HOST="database-server.nithinlearning.site"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload

sudo systemctl start backend

sudo systemctl enable backend

#For this application to work fully functional we need to load schema to the Database.

#We need to load the schema. To load schema we need to install mysql client.

#To have it installed we can use

sudo dnf install mysql -y

#Load Schema

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql

#Restart the service.

sudo systemctl restart backend