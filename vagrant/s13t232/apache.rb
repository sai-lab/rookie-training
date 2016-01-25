package 'apache2'

service 'apache2' do
    subscribes :restart, 'package[apache2]'
end

execute 'echo s13t232 > /var/www/html/index.html' do
    only_if "test -e /var/www/html/index.html"
end
