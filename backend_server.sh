#! /bin/bash

set -x

set -e

set -o

sudo su /home/ec2-user

sudo dnf module disable nodejs -y

sudo dnf module enable nodejs:20 -y

sudo dnf install nodejs -y

#Add application User

useradd expense

#We keep application in one standard location. This is a usual practice that runs in the organization.

#Lets setup an app directory.

mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

unzip /tmp/backend.zip

npm install

#We need to setup a new service in systemd so systemctl can manage this service

vim /etc/systemd/system/backend.service

[Unit]
Description = Backend Service

[Service]
User=expense
Environment=DB_HOST="<MYSQL-SERVER-IPADDRESS>"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend

[Install]
WantedBy=multi-user.target

systemctl daemon-reload

systemctl start backend

systemctl enable backend

#For this application to work fully functional we need to load schema to the Database.

#We need to load the schema. To load schema we need to install mysql client.

#To have it installed we can use

dnf install mysql -y

#Load Schema

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql

#Restart the service.

systemctl restart backend