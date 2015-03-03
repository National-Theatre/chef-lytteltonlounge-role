#
# Cookbook Name:: lytteltonlounge
# Recipe:: _getdata
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

aws_s3_file "/tmp/data.zip" do
  bucket node['lyttenltonlounge']['s3bucket']
  remote_path "#{node['lyttenltonlounge']['s3data']}"
  aws_access_key_id aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  not_if {::File.exists?(node['lytteltonlounge']['www'])}
end