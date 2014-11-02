include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  # デプロイ後の処理
  bash "composer install" do
    code <<-EOS
    cd #{node[:app_root]}; composer install
    EOS
  end

  # 再起動
  %w{php5-fpm nginx}.each do |service_name|
    service service_name do
      action [:start, :restart]
    end
  end

  # tmpディレクトリ作成
  directory "#{node[:app_root]}app/tmp" do
    owner 'deploy'
    group 'www-data'
    mode 0777
    action :create
    not_if {::File.exists?("#{node[:app_root]}app/tmp")}
  end

  # 外部API用Keyの定義
  template "#{node[:app_root]}app/Config/extra_defines.php" do
    mode 0644
    source "extra_defines.php.erb"
  end  

end

