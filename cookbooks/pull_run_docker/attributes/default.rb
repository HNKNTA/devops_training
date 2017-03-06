# -*- mode: ruby -*-
# vi: set ft=ruby :
default["image_name"] = "172.16.32.1:5000/task4"
default["image_version"] = "1.0.51"
default["container_name"] = "tomcat"
default["tomcat_ports"] = [8080, 8081]
