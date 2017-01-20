#!/bin/sh
SERVICE="httpd"

echo "Installing "$SERVICE"..."
yum install $SERVICE -y

echo "Enabling "$SERVICE" service..."
systemctl enable $SERVICE
echo "Starting "$SERVICE" service..."
systemctl start $SERVICE

echo "Opening 80 port..."
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

echo "Copying mod_jk.so..."
cp /vagrant/mod_jk.so /etc/httpd/modules/
echo "Doing chmod..."
chmod +x /etc/httpd/modules/mod_jk.so

echo "Creating workers.properties..."
echo 'worker.list=lb,status
worker.lb.type=lb
worker.lb.balance_workers=tomcat1,tomcat2
worker.tomcat1.host=172.20.20.11
worker.tomcat1.port=8009
worker.tomcat1.type=ajp13
worker.tomcat2.host=172.20.20.12
worker.tomcat2.port=8009
worker.tomcat2.type=ajp13
worker.status.type=status' > /etc/httpd/conf/workers.properties

echo "Adding mod_jk.conf to apache's config directory..."
echo 'LoadModule jk_module modules/mod_jk.so
JkWorkersFile /etc/httpd/conf/workers.properties
JkShmFile /tmp/shm
JkLogFile /var/log/httpd/mod_jk.log
JkLogLevel info
JkMount /test* lb
JkMount /jk-status status' > /etc/httpd/conf.d/mod_jk.conf

echo "Restarting "$SERVICE"..."
systemctl restart httpd
