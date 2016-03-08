node.validate! do
  {
    ruby: {
      version: string
    }
  }
end

execute 'apt-get update'

%w(libffi-dev libreadline6-dev libssl-dev make zlib1g-dev).each do |pkg|
  package pkg
end

minor = node['ruby']['version'].match(/^([0-9]+\.[0-9]+)\.[0-9]+$/)[1]
http_request 'ruby' do
  path "/usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
  url "https://cache.ruby-lang.org/pub/ruby/#{minor}/ruby-#{node['ruby']['version']}.tar.gz"
  not_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
end

execute "tar xf ruby-#{node['ruby']['version']}.tar.gz" do
  cwd '/usr/local/src'
  only_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
  not_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}"
end

execute './configure && make && make install' do
  cwd "/usr/local/src/ruby-#{node['ruby']['version']}"
  not_if "ruby -v | grep ^.*#{node['ruby']['version']}.*$"
end
