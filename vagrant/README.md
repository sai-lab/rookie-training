## Vagrant

[Vagrant](https://www.vagrantup.com/)とは、仮想環境を構築するためのOSSである。  
[VirtualBox](https://www.virtualbox.org/)や[KVM](http://www.linux-kvm.org/)などの仮想化ソフトウェアに対応している。

下記のような`Vagrantfile`と呼ばれるRubyスクリプトに、構成情報を記述する。  
`Vagrantfile`には割り当てるCPUやメモリの量、ネットワークの設定などが含まれる。  
Vagrantは`Vagrantfile`を基に、仮想環境の構築から設定までを自動的に行うことができる。

    VAGRANTFILE_API_VERSION = '2'
    
    Vagrant.configure VAGRANTFILE_API_VERSION do |config|
      config.vm.box = 'ubuntu/trusty64'
      config.vm.hostname = 's00t000'
      config.vm.network :public_network, ip: '192.168.11.40', bridge: 'eth1'
    
      config.vm.provider :virtualbox do |v|
        v.memory = 1024
        v.cpus = 1
      end
    end

`vagrant`コマンドを用いて、仮想環境を操作する。

    $ vagrant up       # 作成・起動
    $ vagrant ssh      # 接続
    $ vagrant halt     # 停止
    $ vagrant destroy  # 削除

#### ネットワーク設定の注意点

Vagrantのネットワーク設定には、下記の3種類がある。

  - プライベートネットワーク: ホストOSとゲストOS間でのみ通信
  - ポートフォワーディング: ホストOSの特定ポートへの接続をゲストOSに転送
  - パブリックネットワーク: ゲストOSがホストOSと同一のネットワークに接続

研究室のサーバでパブリックネットワークを用いる場合、設定に注意する。  
ブリッジに使用するホストOSのネットワークインタフェースを`eth1`に設定する。  
(`eth0`は学内ネットワーク、`eth1`は研究室内ネットワークに接続している。)

    config.vm.network :public_network, bridge: 'eth1'

`eth0`を使用するとDHCP認証で弾かれ、ネットワークに接続できない。
