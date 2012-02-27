#### source: https://github.com/ampledata/chef/blob/master/chef/lib/chef/handler/campfire_handler.rb
###########################3
#
# Author:: Greg Albrecht (<gba@gregalbrecht.com>)
# Copyright:: Copyright (c) 2011 Splunk, Inc. 
# License:: Apache License, Version 2.0
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
# See Also
#  http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers
#  https://github.com/ajsharp/campfire_notifier
#  https://github.com/jnunemaker/httparty
#  https://github.com/mojotech/hipchat/blob/master/lib/hipchat/chef.rb
#  https://github.com/morgoth/hoptoad_handler
#  
#
# Requirements
#  HTTParty gem: $ sudo gem install httparty
#
# Usage
#  1. Add these two lines to your /etc/chef/client.rb
#     require 'campfire_handler'
#     exception_handlers << CampfireHandler.new(:subdomain => 'mycampfire', :token => 'xxx', :room_id => '123')
#  2. Copy this file into /var/chef/handler/
#

require "chef"
require "chef/handler"
require 'rubygems'
require 'httparty'
require 'json'

class CampfireHandler < Chef::Handler
  include HTTParty

  headers     'Content-type' => 'application/json'
  format      :json

  def initialize(opts = {})
    @config = opts
    if @config[:use_system_proxy]
      proxy = @config[:system_proxy].match(/(.*):(\d+)\/?/)
      @proxy_host = proxy[1]
      @proxy_port = proxy[2]
      Chef::Log.info("Using proxy #{@proxy_host}for campfire handler")
    end
  end

  def report()
    begin
      if run_status.failed?
        Chef::Log.error("Creating Campfire exception report")
        CampfireHandler.base_uri    "https://#{@config[:subdomain]}.campfirenow.com"
        CampfireHandler.basic_auth  @config[:token], 'x'
        CampfireHandler.http_proxy(@proxy_host, @proxy_port) if @proxy_host
        CampfireHandler.post "/room/#{@config[:room_id]}/speak.json", 
        :body => { :message => { :body => "#{node.hostname} #{run_status.formatted_exception}", :type => 'TextMessage' } }.to_json
        CampfireHandler.post "/room/#{@config[:room_id]}/speak.json", 
        :body => { :message => { :body => Array(backtrace).join("\n"), :type => 'PasteMessage' } }.to_json
      else
        Chef::Log.info("Creating Campfire run report")
        CampfireHandler.base_uri    "https://#{@config[:subdomain]}.campfirenow.com"
        CampfireHandler.basic_auth  @config[:token], 'x'
        CampfireHandler.http_proxy(@proxy_host, @proxy_port) if @proxy_host
        CampfireHandler.post "/room/#{@config[:room_id]}/speak.json", 
        :body => { :message => { :body => "#{node.hostname} Finished in #{run_status.elapsed_time}", :type => 'TextMessage' } }.to_json
        res_ary = run_status.updated_resources.map do |r|
          r.to_s
        end
        updated_resources = res_ary.join("\n")
        CampfireHandler.post "/room/#{@config[:room_id]}/speak.json", 
        :body => { :message => { :body => "#{node.hostname} updated resources:\n#{updated_resources}", :type => 'PasteMessage' } }.to_json
      end
    rescue Exception => e
      Chef::Log.warn("Campfire handler failed due to #{e.to_s}")
    end
  end
end