#
# Cookbook Name:: lytteltonlounge
# Recipe:: iis
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iis::default"
include_recipe "windows::default"
include Chef::Mixin::PowershellOut

aws_s3_file "c:\lynlge.zip" do
  bucket node['lyttenltonlounge']['s3bucket']
  remote_path "#{node['lyttenltonlounge']['code_url']}"
  not_if {::File.exists?('c:\lynlge.zip')}
end

windows_zipfile node['lytteltonlounge']['www'] do
  source 'c:\lynlge.zip'
  action :unzip
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}\index.html")}
end

aws_s3_file "c:\data.zip" do
  bucket node['lyttenltonlounge']['s3bucket']
  remote_path "#{node['lyttenltonlounge']['s3data']}"
  not_if {::File.exists?('c:\data.zip')}
end

windows_zipfile "#{node['lytteltonlounge']['www']}\_global\db" do
  source 'c:\data.zip'
  action :unzip
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}\_global\db\media.json")}
end

data = powershell_out("Get-S3ObjectMetadata -BucketName #{node['lyttenltonlounge']['s3bucket']} -Key #{node['lyttenltonlounge']['s3data']}")
ruby_block "save_version" do
  block do
    File.new('c:\data_version.txt', 'w') do |f|
      f.puts data.VersionId
    end
  end
  not_if {::File.exists('c:\data_version.txt')}
end


aws_s3_file "c:\lynlgetimeline.zip" do
  bucket node['lyttenltonlounge']['s3bucket']
  remote_path "#{node['lyttenltonlounge']['timeline']}"
  not_if {::File.exists?('c:\lynlgetimeline.zip')}
end

windows_zipfile "#{node['lytteltonlounge']['www']}\timeline" do
  source 'c:\lynlgetimeline.zip'
  action :unzip
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}\timeline\index.html")}
end

iis_site 'Lyttelton Lounge' do
  protocol :http
  port 80
  path "#{node['lytteltonlounge']['www']}"
  host_header "#{node['lytteltonlounge']['vhost']}"
  action [:add,:start]
end