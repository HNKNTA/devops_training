# -*- mode: ruby -*-
# vi: set ft=ruby :

docker_container node["container_name"] do
  repo node["image_name"]
  tag node["image_version"]
  port '8080:8080'
  action :run
end