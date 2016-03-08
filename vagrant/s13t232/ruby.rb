node.validate! do
    {
        ruby: {
            version: string
        }
    }
end

pkg = %w(libffi-dev libreadline6-dev libssl-dev make zlib1g-dev)
minor = node['ruby']['version'].split('.')[0..1].join('.')

execute 'apt-get update'

pkg.each do |name|
    package "ruby" do
        not_if "test -e #{name}"
        action :install
    end
end

http_request "ruby" do
    not_if "test -e /usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
    path "/usr/local/src/ruby-#{node['ruby']['version']}.tar.gz"
    url "https://cache.ruby-lang.org/pub/ruby/#{minor}/ruby-#{node['ruby']['version']}.tar.gz"
end

execute "tar xf ruby-#{node['ruby']['version']}.tar.gz" do
    cwd '/usr/local/src'
end

execute './configure && make && make install' do
    cwd "/usr/local/src/ruby-#{node['ruby']['version']}"
end
