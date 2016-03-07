package 'apache2' do
  action :install
end

service 'apache2' do
  action [:enable, :reload]
end

execute 'create default index.html' do
  command "echo s13t264 > /var/www/html/index.html"
  only_if "test -e /var/www/html/index.html"
end
