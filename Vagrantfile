# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"

  tomcat_count = 3  # number of Tomcats (minimum is 1)
  tomcat_start_ip_octet = 11

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  config.vm.define "apache" do |apache|
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.network "private_network", ip: "172.20.20.10"
    apache.vm.provision "shell",
      path: "./httpd.sh", args: tomcat_count
  end

  (1..tomcat_count).each do |count|
    config.vm.define "tomcat#{count}" do |tomcat|
      tomcat.vm.network "private_network", ip: "172.20.20."+tomcat_start_ip_octet.to_s
      tomcat.vm.provision "shell",
        path: "./tomcat.sh", args: "#{count}"
      tomcat_start_ip_octet += 1
    end
  end

end

