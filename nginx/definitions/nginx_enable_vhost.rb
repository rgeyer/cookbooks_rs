define :nginx_enable_vhost, :fqdn => nil, :aliases => nil, :create_doc_root => true do
  fqdn = params[:fqdn] || params[:name]
  configroot = ::File.join(node[:nginx][:content_dir],fqdn,"nginx-config")
  docroot = ::File.join(node[:nginx][:content_dir],fqdn,"htdocs")
  systemroot = ::File.join(docroot, "system")

  Chef::Log.info "Setting up vhost for fqdn (#{fqdn})"

  if(params[:create_doc_root])
    # Create the sites new home
    directory systemroot do
      mode 0775
      owner "www-data"
      group "www-data"
      recursive true
      action :create
    end

    directory configroot do
      mode 0775
      owner "www-data"
      group "www-data"
      recursive true
      action :create
    end
  end

  # Create a directory for extending the vhost config
  directory "/etc/nginx/sites-available/#{fqdn}.d" do
    recursive true
    action :create
  end

  # START - The equivalent of web_app in the apache2 cookbook
  include_recipe "nginx::config_server"

  template "#{node[:nginx][:dir]}/sites-available/#{fqdn}.conf" do
    source params[:template] || "vhost.conf.erb"
    owner "root"
    group "root"
    mode 0644
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :vhost_name => fqdn,
      :params => params
    )
    if ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/#{fqdn}.conf")
      notifies :restart, resources(:service => "nginx"), :immediately
    end
  end

  nginx_site "#{fqdn}.conf" do
    enable enable_setting
  end
  # /END - The equivalent of web_app in the apache2 cookbook

  right_link_tag "nginx:vhost=#{fqdn}"
end