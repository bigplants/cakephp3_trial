execute "apt-get update" do
  action :nothing
  command "apt-get update"
end

apt_repository "ondrej-php-#{node["lsb"]["codename"]}" do
  uri "http://ppa.launchpad.net/ondrej/php5/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver node["php5_ppa"]["keyserver"]
  key "E5267A6C"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end

packages = %w{bash vim git nginx php5-common php5 php5-mysql php5-curl php5-mcrypt php5-cli php5-fpm php-pear curl imagemagick php5-imagick php5-xdebug php5-gd php5-intl grub gdisk kpartx}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
    version node[:versions][pkg]
  end
end

execute "composer-install" do
  command "curl -sS https://getcomposer.org/installer | php ;mv composer.phar /usr/local/bin/composer"
  not_if { ::File.exists?("/usr/local/bin/composer")}
end

template "/etc/php5/cli/php.ini" do
  mode 0644
  source "php.ini.erb"
end

template "/etc/php5/fpm/php.ini" do
  mode 0644
  source "php.ini.erb"
end

template "/etc/nginx/nginx.conf" do
  mode 0644
  source "nginx.conf.erb"
end

template "/etc/nginx/conf.d/php-fpm.conf" do
  mode 0644
  source "php-fpm.conf.erb"
end

file "/etc/php5/fpm/pool.d/www.conf" do
  action :delete
end

template "/etc/php5/fpm/pool.d/www2.conf" do
  mode 0644
  source "www2.conf.erb"
end

template "/etc/php5/cli/conf.d/timezone.ini" do
  mode 0644
  source "timezone.ini.erb"
end

service 'apache2' do
  action :stop
end

%w{php5-fpm nginx}.each do |service_name|
    service service_name do
      action [:start, :restart]
    end
end
