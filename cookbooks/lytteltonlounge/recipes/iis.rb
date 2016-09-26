#
# Cookbook Name:: lytteltonlounge
# Recipe:: iis
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iis"
include_recipe "windows"
include_recipe "aws"
#include Chef::Mixin::PowershellOut
#require Chef::Mixin::PowershellOut
#Chef::Resource::Execute.send(:include,Chef::Mixin::PowershellOut)
::Chef::Recipe.send(:include, Chef::Mixin::PowershellOut)

#aws_s3_file "z:/lynlge.zip" do
#  bucket node['lytteltonlounge']['s3bucket']
#  remote_path "#{node['lytteltonlounge']['code_url']}"
#  aws_access_key_id creds['AccessKeyId']
#  aws_secret_access_key creds['SecretAccessKey']
#  not_if {::File.exists?('z:/lynlge.zip')}
#end

powershell_script "get code" do
  code <<-EOH
  Read-S3Object -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['code_url']} -File z:\lynlge.zip
  EOH
  not_if {::File.exists?('z:/lynlge.zip')}
end

windows_zipfile "#{node['lytteltonlounge']['www']}" do
  source 'z:/lynlge.zip'
  action :unzip
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}/index.html")}
end

#aws_s3_file "z:\data.zip" do
#  bucket node['lytteltonlounge']['s3bucket']
#  remote_path "#{node['lytteltonlounge']['s3data']}"
#  aws_access_key_id creds['AccessKeyId']
#  aws_secret_access_key creds['SecretAccessKey']
#  not_if {::File.exists?('z:\data.zip')}
#end
powershell_script "get data" do
  code <<-EOH
  Read-S3Object -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['s3data']} -File z:\data.zip
  EOH
  not_if {::File.exists?('z:/data.zip')}
end
powershell_script "get meta" do
  code <<-EOH
  $meta = Get-S3ObjectMetadata -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['s3data']}
  $strFileName="z:\data.txt"
  If (Test-Path $strFileName){
    $oldVersion = Get-Content z:\data.txt
  }Else{
    $oldVersion = ""
  }
  If ($oldVersion -ne $meta.VersionId) {
    $meta.VersionId | Out-File z:\data.txt
    Read-S3Object -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['s3data']} -File z:\data.zip
    Remove-Item #{node['lytteltonlounge']['www']}/_global/db/media.json
  }
  EOH
end

windows_zipfile "#{node['lytteltonlounge']['www']}/_global/db" do
  source 'z:\data.zip'
  action :unzip
  overwrite true
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}/_global/db/media.json")}
end

#data = powershell_out("Get-S3ObjectMetadata -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['s3data']}")
#ruby_block "save_version" do
#  block do
#    puts data.inspect
#    puts data.stdout
#    require 'json'
#    puts JSON.parse("{#{data.stdout}}")
#    File.new('c:\data_version.txt', 'w') do |f|
#      f.puts data.VersionId
#    end
#  end
#  not_if {File.exist?('c:\data_version.txt')}
#end


#aws_s3_file "z:\lynlgetimeline.zip" do
#  bucket node['lytteltonlounge']['s3bucket']
#  remote_path "#{node['lytteltonlounge']['timeline']}"
#  aws_access_key_id creds['AccessKeyId']
#  aws_secret_access_key creds['SecretAccessKey']
#  not_if {::File.exists?('z:\lynlgetimeline.zip')}
#end
powershell_script "get timeline" do
  code <<-EOH
  Read-S3Object -BucketName #{node['lytteltonlounge']['s3bucket']} -Key #{node['lytteltonlounge']['timeline']} -File z:\lynlgetimeline.zip
  EOH
  not_if {::File.exists?('z:/lynlgetimeline.zip')}
end

windows_zipfile "#{node['lytteltonlounge']['www']}/timeline" do
  source 'z:\lynlgetimeline.zip'
  action :unzip
  not_if {::File.exists?("#{node['lytteltonlounge']['www']}/timeline/index.html")}
end

iis_pool 'Lyttelton Lounge' do
  runtime_version "4.0"
  pipeline_mode :Classic
  action :add
end

iis_site 'Lyttelton Lounge' do
  protocol :http
  port 80
  path "#{node['lytteltonlounge']['www']}"
  host_header "#{node['lytteltonlounge']['vhost']}"
  application_pool 'Lyttelton Lounge'
  action [:add,:start]
end
