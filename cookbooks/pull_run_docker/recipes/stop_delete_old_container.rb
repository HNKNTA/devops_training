# -*- mode: ruby -*-
# vi: set ft=ruby :

old_container = `docker ps -q | tail -n 1`.strip

docker_container old_container do
  action [:stop, :delete]
end

