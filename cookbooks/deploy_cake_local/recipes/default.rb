bash "run cake console command" do
  code <<-EOS
    cd #{node[:app_root]}app; composer install
    cp app.default.php app.php
  EOS
end

# xdebugの設定
template "/etc/php5/fpm/conf.d/20-xdebug.ini" do
  mode 0644
  source "20-xdebug.ini.erb"
end
template "/etc/php5/cli/conf.d/20-xdebug.ini" do
  mode 0644
  source "20-xdebug.ini.erb"
end

%w{php5-fpm nginx}.each do |service_name|
    service service_name do
      action [:start, :restart]
    end
end
