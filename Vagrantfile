# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    
    # LAN?
    #vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
 
    # Customize the amount of memory on the VM:
    #vb.memory = "1024"
  end

  config.vm.define "server1" do |server1|
    server1.vm.provision "yum", type: "shell",
     inline: "yum install git -y"
    server1.vm.provision "git", type: "shell", privileged: false,
     inline: $git_script
  end

  config.vm.define "server2"
end

$git_script = <<SCRIPT
echo 'clonning the repo'
git clone https://github.com/HNKNTA/devops_training.git
echo 'cd to the repo directory'
cd devops_training/
echo 'changing the branch'
git checkout -b task1
SCRIPT
