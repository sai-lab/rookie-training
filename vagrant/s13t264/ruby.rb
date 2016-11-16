node.validate! do
  {
    ruby: {
      version: string,
    },
  }
end

execute 'apt-get-update' do
  command 'apt-get update -y'
end

%w(libffi-dev libreadline6-dev libssl-dev make zlib1g-dev).each do |value|
  package value
end

http_request "install-ruby-2.3.0" do
  minor = node['ruby']['version'].split('.')[0..1].join('.')
  url "https://cache.ruby-lang.org/pub/ruby/#{minor}/ruby-#{node['ruby']['version']}.tar.gz"
  path "/usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
  not_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
end

execute 'tar ruby-2.3.0' do
  cwd '/usr/local/src'
  command "tar xf ruby-#{node['ruby']['version']}.tar.gz"
  not_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}"
end

execute 'configure & make ruby-2.3.0' do
  cwd "/usr/local/src/ruby-#{node['ruby']['version']}"
  command './configure && make && make install'
  not_if "ruby -v | grep #{node['ruby']['version']}"
end
