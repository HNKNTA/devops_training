# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  config.vm.define "apache" do |apache|
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.network "private_network", ip: "172.20.20.10"
    apache.vm.provision "shell",
      path: "./httpd.sh"
  end

  config.vm.define "tomcat1" do |tomcat1|
    tomcat1.vm.network "private_network", ip: "172.20.20.11"
    tomcat1.vm.provision "shell",
      path: "./tomcat.sh", args: "1"
  end

  config.vm.define "tomcat2" do |tomcat2|
    tomcat2.vm.network "private_network", ip: "172.20.20.12"
    tomcat2.vm.provision "shell",
      path: "./tomcat.sh", args: "2"
  end

end

