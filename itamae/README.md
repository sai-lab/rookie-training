## Itamae

[Itamae](http://itamae.kitchen)とはRuby製の構成管理ツールである。  
[Chef](https://www.chef.io)を参考にしているが、よりシンプルで軽量である。

  - ChefにおけるCookbookやRoleなどの概念がない。
    - 低い学習コストで使用することができる。
  - 対象サーバにItamaeをインストールする必要がない。
    - SSH経由でプロビジョニングできる。

クックパッドが中心となって開発が進められている。  
詳細については、開発者ブログを参照すること。

  - [クックパッドのサーバプロビジョニング事情 - クックパッド開発者ブログ](http://techlife.cookpad.com/entry/2015/05/12/080000)

#### インストール

事前にRubyをインストールしておく必要がある。  
システムに直接インストールする場合は、Gemを利用する。

```
$ sudo gem install itamae
```

しかし、アップデートによってRecipeを実行できなくなる可能性がある。  
そのため、Gemfileを設置してBundlerを利用することが推奨されている。

```ruby
# Gemfile
source 'https://rubygems.org'
gem 'itamae'

# $ sudo gem install bundler
# $ bundle install
```

#### Recipe

Itamaeでは処理を記述したRubyスクリプトを「Recipe」と呼ぶ。  
「パッケージのインストール」「コマンドの実行」などは[Resource](https://github.com/itamae-kitchen/itamae/wiki/Resources)を通して実行する。  
下記に `sl` コマンドをインストールするRecipeの例を示す。

```ruby
package 'sl' do
  action :install
end
```

その他の機能については[Wiki](https://github.com/itamae-kitchen/itamae/wiki)を参照すること。

#### Vagrantでの利用

VagrantfileでRecipeを指定することで、プロビジョニングにItamaeを利用できる。  
ただし[vagrant-itamae](https://github.com/chiastolite/vagrant-itamae)が必要なため、事前に `vagrant plugin install vagrant-itamae` でインストールしておく。  
初回の`vagrant up`時に実行される他、`vagrant provision`で手動で実行できる。  

```ruby
Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  ...

  config.vm.provision :itamae do |itamae|
    itamae.sudo = true
    itamae.recipes = ['/path/to/default.rb']
  end
end
```
