# tmpディレクトリ作成
directory "#{node[:app_root]}app/tmp" do
  owner 'vagrant'
  group 'vagrant'
  mode 0777
  action :create
  not_if {::File.exists?("#{node[:app_root]}app/tmp")}
end

bash "run cake console command" do
  code <<-EOS
    cd #{node[:app_root]}; composer install
    cd #{node[:app_root]}app; yes | ./Console/cake migrations.migration run all
    cd #{node[:app_root]}app; yes | ./Console/cake data local_test_import
    ./Console/cake remove_cache
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
