#
# Cookbook Name:: lytteltonlounge
# Recipe:: nginx
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx::default"

package "unzip" do
  action :install
end

remote_file "/tmp/lytteltonlounge.zip" do
  source node['lyttenltonlounge']['code_url']
  mode "0644"
  not_if { ::File.exists?("#{node['lytteltonlounge']['www']}/index.html") }
end

execute "install-lytteltonlounge" do
  cwd node['lytteltonlounge']['www']
  command <<-EOF
    unzip /tmp/lytteltonlounge.zip
  EOF
  not_if { ::File.exists?("#{node['lytteltonlounge']['www']}/index.html") }
end