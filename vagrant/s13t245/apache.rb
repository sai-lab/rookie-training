package 'apache2'

service 'apache2' do
  subscribes :restart, 'package[apache2]'
end

execute 'echo hello itamae 4 > /var/www/html/index.html' do
  only_if 'test -e /var/www/html/index.html'
end

template 'create index' do
  path '/var/www/html/index.html'
  user 'root'
  group 'root'
  mode '644'
end
