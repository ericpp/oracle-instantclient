#
# Cookbook Name:: cla_unix_baseline
# Recipe:: web_packages
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

ubuntu_lucid_plist = %w( python-adodb python-django python-django-doc 
python-django-djapian python-django-dmigrations python-django-evolution 
python-django-formfieldset python-django-lint python-django-south
)

# STUB:
rh_5_plist = %w( 
)

gem_list = %w( 
)

case node[:platform]
when "ubuntu"
  ubuntu_lucid_plist.each do |pkg|
    package pkg
  end
when "redhat", "centos" 
  rh_5_plist.each do |pkg|
    package pkg
  end
end

gem_list.each do |gem|
  gem_package gem
end