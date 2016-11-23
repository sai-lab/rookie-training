# Docker#section08 : Dockerfileとシェルスクリプトの連携

Dockerfileでは`RUN`や`CMD`を使うことで，コンテナ内でコマンドの実行ができることは既にわかったと思います．  
しかし，これらだけでは自動化の難しい場合も出てきます．  
その場合は，シェルスクリプトを別に作成し，それをDockerfileから実行するといった形をとります．  

## シェルスクリプトの作成

始めに，Dockerfileから参照する`create_app.sh`と`init.sh`を作ります．  

まずは作業用ディレクトリを作成し，移動します．

```
mkdir ~/build_rails
cd ~/build_rails
```

次に，`create_app.sh`を以下の内容で作成してください．  
このシェルスクリプトではRailsを用いて，簡易的な伝言板アプリケーションを作成しています．  
(RailsはRubyのウェブアプリケーションフレームワーク．)  
Dockerを理解する上では，このシェルスクリプトをちゃんと理解する必要はないです

```
#!/bin/bash -x

mkdir /root/rails
cd /root/rails
rails new dengonban
cd dengonban
echo "gem 'therubyracer', platforms: :ruby" >> Gemfile
sed -i "s/# \{config.time_zone\} =.*/\1 = 'Tokyo'/" \
       config/application.rb
sed -i "s/# \{config.serve_static_assets\} =.*/\1 = true/" \
       config/environments/production
RAILS_ENV=production bundle exec rake assets:precompile
rails generate scaffold Message name:string content:text date:datetime
rake db:migrate RAILS_ENV="production"
```


続いて，`init.sh`を以下の内容で作成してください．  
`export ～`から`rails ～`ではRailsアプリを起動しています．(Dockerを理解する上では，ここは理解してなくても問題ないです)  
それ以降では，TERMシグナルを受信したときRailsを停止するようにし，その後にbashを起動しています．

```
#!/bin/bash

export SECRET_KEY_BASE=\
$(ruby -e 'require "securerandom"; print SecureRandom.hex(64)')
cd /root/rails/dengonban
rails s -e production -p 80 -d

cat <<EOF >>~/.bashrc
trap 'pkill -TERM ruby-mri; sleep 3;exit 0' TERM
EOF
exec /bin/bash
```

#### 実行するコマンド群

```
mkdir ~/build_rails
cd ~/build_rails
nano create_app.sh
nano init.sh
```

## Dockerfileの作成

続いて，以下の内容のDockerfileを作成します．  
作業は先ほどと同じ`build_rails`の下で行います．  

ここでは上から順に
- 必要なパッケージのインストール
- `create_app.sh`のコンテナ内へのコピーと実行
- `init.sh`のコンテナ内へのコピーと実行

を行っています．

```
FROM enakai00/fedora:21
MAINTAINER s00t000

RUN yum install -y make gcc gcc-c++ ruby-devel rubygem-rails \
                   rubygem-therubyracer libsqlite3x-devel
ADD create_app.sh /usr/local/bin/create_app.sh
RUN chmod u+x /usr/local/bin/create_app.sh
RUN /usr/local/bin/create_app.sh
ADD init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh
CMD ["/usr/local/bin/init.sh"]
```

#### 実行するコマンド群

```
nano Dockerfile
```

## コンテナイメージをビルドする

それでは以下のコマンドを実行して，コンテナイメージを作成しましょう．

```
docker build -t vagrant/rails:ver1.0 .
```

## ポートフォワードの設定

コンテナを起動する前に，ブラウザからWebページにアクセスするためにポートフォワードの設定をします．  
[詳しくはこちら](https://github.com/sai-lab/rookie-training/blob/master/docker/StartApache.md#ポートフォワードの設定)を見てください．  
(既にやってる人はここは飛ばしてください．)

## コンテナの起動

それでは実際にコンテナを起動して動作を確認してみましょう．  
コンテナの起動は以下のコマンドで行います．

```
docker run -itd -p 8000:80 --name rails01 vagrant/rails:ver1.0
```

上記コマンドを実行したら，念のため以下のようにコマンドを実行して，コンテナが起動しているかを確かめてみましょう．  
同じような結果が表示されていれば起動できています．

```
$ docker ps -l
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                  NAMES
40788276a9cd        vagrant/rails:ver1.0   "/usr/local/bin/init."   36 minutes ago      Up 21 minutes       0.0.0.0:8000->80/tcp   rails01
```

## Webページの確認

これまでの手順でコンテナ上でサービスが運用されていると思います．  
ブラウザから`http://133.92.147.245:10100/messages`(10100は各自で適当なポート番号を指定)  
にアクセスして確認してみましょう．  

「Listing messages」と書かれたWebページが表示されればうまく起動できています．
「New Message」から新しくメッセージを書いて「Create Message」，そして「Back」で戻ると最初のページに，先ほど新しく書いたメッセージが表示されると思います．

## コンテナイメージの保存，コンテナの停止・削除

それぞれ以下のコマンドを実行します．  
`rails01`としてるところはコンテナ名，`vagrant/rails:ver1.1`としてるところはイメージ名を指定しています．  
コンテナが別の名前だったり，イメージを別の名前にしたい場合は適宜変更してください．

#### コンテナイメージの保存

```
docker commit rails01 vagrant/rails:ver1.1
```

#### コンテナの停止

```
docker stop rails01
```

#### コンテナの削除

```
docker rm rails01
```

---

これでDocker入門講座は終了です.(予定)   
関連ツールや発展的な内容を付録に追記する予定です．
[README](./README.md) に戻る．
