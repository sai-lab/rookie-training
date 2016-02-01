p node

package 'apache2' do
  action :install
end

service 'apache2' do
  action [:restart]
end

execute 'echo html' do
  command 'echo apache2 > /var/www/html/index.html'
end
