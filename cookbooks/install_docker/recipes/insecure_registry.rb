# -*- mode: ruby -*-
# vi: set ft=ruby :

ruby_block "insert_line" do
  block do
    config_line = "INSECURE_REGISTRY='--insecure-registry %s'" % [node["docker_insecure_registry_ip"]] 
    file = Chef::Util::FileEdit.new(node["docker_config_file"])
    file.insert_line_if_no_match(config_line, config_line)
    file.write_file
  end
end