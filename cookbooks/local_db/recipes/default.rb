execute "apt-get update" do
  action :nothing
  command "apt-get update"
end

apt_repository "mysql-5.6" do
  uri "http://ppa.launchpad.net/ondrej/mysql-5.6/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keys.gnupg.net"
  key "E5267A6C"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end

packages = %w{mysql-server mysql-client}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
    version node[:versions][pkg]
  end
end


template "/etc/mysql/my.cnf" do
  mode 0644
  source "my.cnf.erb"
end

file "/usr/my.cnf" do
  action :delete
end

%w{mysql}.each do |service_name|
    service service_name do
      action [:start, :restart]
    end
end

bash "create local db" do
  code <<-EOS
    mysql -u root --execute  "create database if not exists myapp"
    mysql -u root --execute  "create database if not exists myapp_test"
  EOS
end