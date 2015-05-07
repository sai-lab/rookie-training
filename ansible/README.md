## Ansible

[Ansible](http://www.ansible.com)とはPython製の構成管理ツールである。  
[Chef](https://www.chef.io)など他の構成管理ツールと比較して、以下のような特徴がある。

  - 対象ホストに特別なソフトウェア(エージェント)が必要ない。
  - Playbook(レシピ)をシンプルな[YAML](http://yaml.org)形式で記述できる。
  - Playbookが記述した順番通りに実行される。

#### 構成管理ツール

ソフトウェアのインストールや設定などをコードに記述し、それを実行するツールのことである。  
(これを「プロビジョニング」と呼ぶ。)  
コードに記述することで、自動化したり、複数のサーバに実行したりすることができる。

また、構成管理ツールでは「冪等性(べきとうせい)」が保証されていることが多い。  
これはプロビジョニングを何回実行しても結果は同じ、という性質である。

#### Playbook

Ansibleでは処理を記述したYAMLファイルを「Playbook」と呼ぶ。  
「パッケージのインストール」「コマンドの実行」などは[Module](http://docs.ansible.com/modules_by_category.html)を通して実行する。  
下記にホスト名とIPアドレスをデバッグ出力するPlaybookの例を示す。

    ---
    - hosts: all
      sudo: yes
      gather_facts: yes
      tasks:
        - debug: msg="hostname = {{ ansible_hostname }}"
        - debug: msg="eth1.ipv4.address = {{ ansible_eth1.ipv4.address }}"

#### Vagrantでの利用

VagrantfileでPlaybookを指定することで、プロビジョニングにAnsibleを利用できる。  
初回の`vagrant up`時に実行される他、`vagrant provision`で手動で実行できる。

    Vagrant.configure VAGRANTFILE_API_VERSION do |config|
      ...

      config.vm.provision 'ansible' do |ansible|
        ansible.playbook = '/path/to/main.yml'
      end
    end
