#
# Cookbook Name:: zend-server
# Recipe:: default
#
# Copyright 2013, Zend
#
# All rights reserved - Do Not Redistribute
#
log "adding repository"

# check before install that a suitable key is provided, if not bail out
# Chef::Application.fatal!("Zend Server Order number has to be supplied", 2) if node[:zendserver][:ordernumber].nil? || node[:zendserver][:ordernumber].empty?
# Chef::Application.fatal!("Zend Server Serial has to be supplied", 2) if node[:zendserver][:licensekey].nil? || node[:zendserver][:licensekey].empty?

version = node[:zendserver][:version]
phpversion = node[:zendserver][:phpversion]
url = node[:zendserver][:url]
basedirdeb = node[:zendserver][:basedirdeb]
basedirrpm = node[:zendserver][:basedirrpm]

case node[:zendserver][:nginx]
when true 
package_name = "zend-server-nginx-php-#{phpversion}"
when false
package_name = "zend-server-php-#{phpversion}"
else
package_name = "zend-server-php-#{phpversion}"
end

puts #{package_name}

case node["platform_family"]
when "debian"
  include_recipe "apt::default"
  # do things on debian-ish platforms (debian, ubuntu, linuxmint)

	log "Url: #{url}#{version}/#{basedirdeb}/"
	apt_repository "zend-server" do
	  uri "#{url}#{version}/#{basedirdeb}/"
	  components ["server","non-free"]
	  key "http://repos.zend.com/zend.key"
	  action :add
	  notifies :run, "execute[apt-get update]", :immediately
    end
when "rhel"
  yum_key "zend-server" do
  	url "http://repos.zend.com/zend.key"
  	action :add
  end

  # do things on RHEL platforms (redhat, centos, scientific, etc)
  yum_repository "zend-server" do
	description "Zend Server repo"
	url "#{url}/#{version}/#{basedirrpm}/$basearch"
  	action :add
  end

  yum_repository "zend-server-noarch" do
	description "Zend Server repo"
	url "#{url}/#{version}/#{basedirrpm}/noarch"
  	action :add
  end

when "suse"
  include_recipe "zypper::default"
  zypper_repository "zend-server" do
    	uri "http://repos.zend.com/zend-server/#{version}/sles/ZendServer-x86_64"
	key "http://repos.zend.com/zend.key"
   	title "zend-server-#{version}"
	action :add
  end
  zypper_repository "zend-server-noarch" do
	uri "http://repos.zend.com/zend-server/#{version}/sles/ZendServer-noarch"
	key "http://repos.zend.com/zend.key"
	title "zend-server-noarch-#{version}"
	action :add
  end
end

log "Starting install for package #{package_name}"
package package_name do
	:install
  notifies :restart, 'service[zend-server]', :immediate if node["platform_family"] == "rhel"
end

#HOT FIX for bug ZSRV-10761 at line 4
# options.noCache = true;
#template "/usr/local/zend/gui/public/js/zswebapi.js" do
#  source "zswebapi.js.erb"
#  mode 0644
#  owner "root"
#  group "root"
#end

# Problem with CentOS api functions if server not restarted
service "zend-server" do
<<<<<<< HEAD
	action :restart
=======
	action :nothing
>>>>>>> FETCH_HEAD
end
