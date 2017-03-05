# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'net/http'

def check_port(port)
  begin
    Net::HTTP.get(URI.parse('http://localhost:' + port.to_s))
    true
  rescue Errno::ECONNREFUSED
    false
  end
end

def get_tomcat_port
  node["tomcat_ports"].each do |port|
    unless check_port(port)
      return port.to_s
    end
  end
end

tomcat_port = get_tomcat_port()
puts "tomcat_port = " + tomcat_port

docker_container node["container_name"] + Time.now.to_i.to_s do
  repo node["image_name"]
  tag node["image_version"]
  port "#{tomcat_port}:8080"
  action :run
end

