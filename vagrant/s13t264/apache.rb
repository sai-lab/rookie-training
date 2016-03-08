package "apache2"

service "apache2" do
  action [:enable, :reload]
end

template "/var/www/html/index.html" do
  action :create
  user 'root'
  group 'root'
  mode '644'
  variables(message: "World")
end
