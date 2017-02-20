# -*- mode: ruby -*-
# vi: set ft=ruby :

service "docker" do
  action [:enable, :start]
end