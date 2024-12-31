#! /bin/bash

set -x

set -e

set -o

cd /home/ec2-user || exit

#Install Nginx

sudo dnf install nginx -y 

#Enable nginx

sudo systemctl enable nginx

#Start nginx

sudo systemctl start nginx

#Remove the default content that web server is serving.

rm -rf /usr/share/nginx/html/*

#Download the frontend content

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip

#Extract the frontend content.

cd /usr/share/nginx/html

unzip /tmp/frontend.zip

#Create Nginx Reverse Proxy Configuration.

sudo bash -c 'cat <<EOF >  /etc/nginx/default.d/expense.conf
proxy_http_version 1.1;

location /api/ { proxy_pass http://backend-server.nithinlearning.site:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF'

#Restart Nginx Service to load the changes of the configuration.

sudo systemctl restart nginx