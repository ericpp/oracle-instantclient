#
# Cookbook Name:: cla_unix_baseline
# Recipe:: class_dbserver
#
# Copyright 2011, Joshua Buysse, (C) Regents of the University of Minnesota
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# slightly modified from appbase recipe, to install the PHP tools without Apache
# allow code to run, but no vhosts or a few added bits

## merged from class perl::modules and freetds
##   

# merged from many of their cookbooks.
# installing php5-cli here to prevent the php5 metapackage from installing apache
ubuntu_lucid_plist = %w{ php5-cli php5-sqlite freetds-bin }

### no nodes expected on rhel but maintaining as much as possible in case of future use
rh_5_plist = %w{ php-cli freetds }

case node[:platform]
when "ubuntu"
  ubuntu_lucid_plist.each do |pkg|
    package pkg
  end  
  perl_modules = %w{ libdbi-perl libdbd-mysql-perl libnet-ssleay-perl libdigest-sha1-perl 
    libtimedate-perl libio-zlib-perl libarchive-zip-perl libdate-manip-perl libcurses-perl 
    libalgorithm-diff-perl }
  
when "redhat", "centos" 
  Chef::Log.warn("CLASS packages may not be fully implemented for platform")
  rh_5_plist.each do |pkg|
    package pkg
  end
  perl_modules = %w{ perl-DBI perl-DBD-MySQL perl-Net-SSLeay perl-Digest-SHA1 perl-TimeDate 
    perl-IO-Zlib perl-Archive-Zip perl-Archive-Tar perl-DateManip perl-Curses perl-Algorithm-Diff }
  
end

### ensure perl, from CLASS perl::modules recipe
include_recipe "perl"

include_recipe "mysql::client"
#include_recipe "apache2::default"
#include_recipe "apache2::mod_deflate"
#include_recipe "apache2::mod_rewrite"
#include_recipe "apache2::mod_ssl"

## need a bunch of php stuff
include_recipe "php::default"

# this will overwrite php.ini and other stuff
# we include from opscode recipe where possible, so that
# the resource providers don't get overwritten
include_recipe "class_php::default"
include_recipe "php::module_curl"
include_recipe "class_php::module_mssql"
include_recipe "php::module_mysql"
include_recipe "class_php::module_pdo"
include_recipe "class_php::module_posix"
include_recipe "class_php::module_xml"
include_recipe "class_php::module_xsl"

include_recipe "class_dbrep::default"

# from perl::modules as modified by CLASS
perl_modules.each do |pkg|
  package pkg do
    action :install
  end
end

# from freetds::default
template "/etc/freetds.conf" do
  source "freetds.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

# sudo commands for managing mysql and chef
cla_sudo_commands "class_dbserver" do
  allowed_group "classadm"
  target_user "root"
  commands [
    "/etc/init.d/mysqld_prod *",
    "/etc/init.d/mysqld_test *",
    "/etc/init.d/mysqld_dev *",
    "/etc/init.d/mysqld_staging *",
    "/sbin/service mysqld_prod *",
    "/sbin/service mysqld_test *",
    "/sbin/service mysqld_dev *",
    "/sbin/service mysqld_staging *",
    "/usr/bin/chef-client \"\"",
    "/var/lib/gems/1.8/bin/chef-client \"\""
  ]
end
