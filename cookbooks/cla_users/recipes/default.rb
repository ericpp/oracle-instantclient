#
# Cookbook Name:: cla_users
# Recipe:: local_admins
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

## large portions have been rewritten from CLASS users cookbook, by Eric Perrino

gem_package "libshadow"

additional_groups = Hash.new

# fixes CHEF-1699
# needed for RHEL 5.x, according to bug.  Should be fixed in core chef (COOK-517), but
# this workaround is harmless to ensure safety. 
ruby_block "reset group list" do
  block do
    Etc.endgrent
  end
  action :nothing
end

home_base_dir = node[:cla_users][:local_user_home] ? node[:cla_users][:local_user_home] : "/home"

#### we need to *not* apply these rules on machines that have
#### integration -- this is the "out" that can be set on an integration role
if not node['cla_users']['ignore_local_users'] then 

  search(:local_users) do |u|
    if (u['server_roles'] & node['roles'])
      # append user's additional groups to additional_groups
      if not u['groups'].nil?
        u['groups'].each do |g|
          log "Group found: #{g} for #{u['id']}"
          if not additional_groups.has_key?(g)
            additional_groups[g] = Array.new
          end
          additional_groups[g] << u['id']
        end
      end

      if u['home_dir'] then
        home_dir = u['home_dir']
      else
        home_dir = "#{home_base_dir}/#{u['id']}" 
      end

      # add the user to the system
      user u['id'] do
        uid u['uid'] if u['uid']
        gid u['gid'] if u['gid']
        shell u['shell'] if u['shell']
        comment u['comment'] if u['comment']
        if (node[:cla_users][:local_users_use_password] and u['password_hash']) then
          password u['password_hash']
        end
        home "/home/#{u['id']}"
        supports :manage_home => true
        notifies :create, "ruby_block[reset group list]", :immediately
        action [:create, :manage, :modify]
      end

      # add authorized_keys file (if any)
      if (node[:cla_users][:local_users_add_ssh_keys] and u.has_key?('authorized_keys')) then
        directory "/home/#{u['id']}/.ssh" do
          owner u['id']
          mode 0700
        end
        template "/home/#{u['id']}/.ssh/authorized_keys" do
          source "authorized_keys.erb"
          owner u['id']
          mode 0600
          variables(:authorized_keys => secret['authorized_keys'])
          action :create_if_missing
        end
      end
    end
  end

  # assign users to additional groups
  additional_groups.each do |g,u|
    group g do
      ginfo = Hash.new
      # data bag item is optional, catch the exception
      begin
        ginfo = data_bag_item(:local_groups, g)
      rescue Exception => e
        nil
      end
      if ginfo['users'] then
        ginfo['users'].each do |adduser| 
          u << adduser
        end
      end
      gid ginfo['gid'] if ginfo['gid']
      members u
      append false
      action [:create, :modify, :manage]
    end
  end

end # ignore_local_users is false