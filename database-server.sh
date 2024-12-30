#! /bin/bash

set -x

set -e

set -o

sudo su ~

cd /

#Install MySQL Server 8.0.x

dnf install mysql-server -y

#Start MySQL Service

systemctl enable mysqld

systemctl start mysqld

systemctl status mysqld

#Next, We need to change the default root password in order to start using the database service. Use password ExpenseApp@1 or any other as per your choice.

mysql_secure_installation --set-root-pass ExpenseApp@1

#But if your client and server both are in a single server, you can simply issue.

mysql

#Once you got mysql prompt, you can use below command to check schemas/databases exist.

show databases;

#Once you are in particular schema, you can get the list of tables.

show tables;
