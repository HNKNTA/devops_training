#!/bin/sh
SERVICE="tomcat"

echo "Installing JRE..."
yum install java-1.8.0-openjdk -y

echo "Installing "$SERVICE"..."
yum install $SERVICEi tomcat-webapps tomcat-admin-webapps -y

echo "Enabling "$SERVICE" service..."
systemctl enable $SERVICE
echo "Starting "$SERVICE" service..."
systemctl start $SERVICE

echo "Opening 8009 port..."
firewall-cmd --zone=public --add-port=8009/tcp --permanent
firewall-cmd --reload

echo "Creating HTML index page..."
_dir=/usr/share/tomcat/webapps/test
mkdir -p $_dir
echo "Tomcat "$1 > $_dir/index.html 
