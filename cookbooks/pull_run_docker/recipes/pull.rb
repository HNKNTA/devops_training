# -*- mode: ruby -*-
# vi: set ft=ruby :

docker_image node["image_name"] do
  tag node["image_version"]
  action :pull_if_missing
end