# Vagrant#section03 Vagrantを使ってみよう

それではVagrantを実行してみましょう．

研修用サーバにログインして下さい．

`~/vagrant`というディレクトリを作成してください．

```
mkdir ~vagrant && cd ~/vagrant
```

## Vagrant Boxの追加

次に，仮想マシンを構築するための元になるイメージファイルを取得しましょう．  
Vagrantでは[Vagrant Box](http://www.vagrantbox.es/)に様々なイメージが公開されています．  
基本的に始めにVagrantで環境構築するときには，ここからダウンロードしてくることが多いです．  
チームメンバで同じイメージを利用するようなこともできます．

今回は，みんなでダウンロードをすると時間がかかってしまうので  
ローカルに保存しているイメージを使います．

イメージを追加するには，`vagrant box add`コマンドを使います．  
書式は以下の通りです．

`vagrant box add {追加した後のBOX名} {追加するBOXイメージのパス}`

ここでは，以下のように実行してください．

```
vagrant box add ubuntu/trusty64 /home/joniy/vagrant-boxes/trusty64.box
```

これでBoxが追加されました．  

boxは`vagrant box list`コマンドで確認できます．
実行すると以下のように表示されると思います．

```
$ vagrant box list
ubuntu/trusty64     (virtualbox, 0)
```

## Vagrantfileの作成

続いて，Vagrantの設定ファイルVagrantfileを作って行きましょう．
`vagrant init`コマンドを使うことで，初期状態のVagrantfileを生成することができます．
以下のコマンドを実行してください．

```
$ vagrant init ubuntu/trusty64
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```

Vagrantfileがカレントディレクトリに生成されていると思います．  
Vagrantfileはrubyと同じように記述できます．  
中を見てみると設定例がコメントアウトされて色々示されています．

次に，仮想マシンの状態を確認します．
`vagrant status`コマンドを使うことで仮想マシンの状態を確認することが出来ます．  
実行すると以下のように表示されると思います．  
まだ設定ファイルを生成しただけで，仮想マシンを起動していないので，  
`not created`と出ます．

```
$ vagrant status
Current machine states:

default                   not created (virtualbox)

The environment has not yet been created. Run `vagrant up` to
create the environment. If a machine is not created, only the
default provider will be shown. So if a provider is not listed,
then the machine is not created for that environment.
```

Vagrantfileを編集しましょう．  
以下のようにVagrantfileの中身を書き換えて下さい．  
各設定項目の詳しい説明は後で行います．
6行目の`s00t000`の部分は各自の学籍番号に書き換えてください．


```
# -*- mode: ruby -*-
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.hostname = 's00t000'
  config.vm.network :public_network, bridge: 'eth1'

  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.cpus = 1
  end
end
```

それでは仮想マシンを起動しましょう．  
`vagrant up`コマンドを使うことで，Vagrantfileに基づいた仮想マシンを起動出来ます．

```
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
...
```

これで仮想マシンを起動することができました．

# 参考資料

- [Vagrant体験入門ハンズオン手順](http://qiita.com/shin1x1/items/3288d9de7f04192b6ad8)

---

次のセクション [section04 : Vagrantのライフサイクル](./LifeCycle.md) へ進む.  
[README](./README.md) に戻る．
