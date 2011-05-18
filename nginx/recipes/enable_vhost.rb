nginx_enable_vhost "Vhost" do
  fqdn node[:nginx][:vhost_fqdn]
  aliases node[:nginx][:aliases]
end