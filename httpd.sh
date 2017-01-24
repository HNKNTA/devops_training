#!/bin/sh
SERVICE="httpd"
WORKERS_FILENAME=/etc/httpd/conf/workers.properties
START_IP_OCTET=11


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
_workers_str="worker.lb.balance_workers="
echo 'worker.list=lb,status
worker.lb.type=lb
worker.status.type=status' > $WORKERS_FILENAME
for ((i = 1 ; i <= $1 ; i++)); do
  _workers_str=$_workers_str"tomcat"$i
  if [ $i != $1 ]
  then
    _workers_str=$_workers_str","
  fi
  echo 'worker.tomcat'$i'.host=172.20.20.'$((START_IP_OCTET++))'
worker.tomcat'$i'.port=8009
worker.tomcat'$i'.type=ajp13' >> $WORKERS_FILENAME
done
echo $_workers_str >> $WORKERS_FILENAME

echo "Adding mod_jk.conf to apache's config directory..."
echo 'LoadModule jk_module modules/mod_jk.so
JkWorkersFile /etc/httpd/conf/workers.properties
JkShmFile /tmp/shm
JkLogFile /var/log/httpd/mod_jk.log
JkLogLevel info
JkMount /test* lb
JkMount /jk-status status' > /etc/httpd/conf.d/mod_jk.conf

echo "Restarting "$SERVICE"..."
systemctl restart $SERVICE
