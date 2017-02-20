include_recipe 'install_docker::install'
include_recipe 'install_docker::insecure_registry'
include_recipe 'install_docker::run_and_enable'