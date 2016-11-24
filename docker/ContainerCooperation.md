# Docker#appendix01 : コンテナ間の連携

複数のコンテナを用いて，各コンテナを連携させて1つのサービスを運用してみます．  
ここでは例として，短縮URLを生成するサービスをMySQLとNode.jsを用いて作ります．

## MySQLのコンテナ作成

始めにMySQLのコンテナを作成していきます．  
作業は以下のように作業ディレクトリを作成し，その中で行っていきます．

```
mkdir ~/build_mysql
cd ~/build_mysql
```

### シェルスクリプトを作成

ここでもシェルスクリプトと連携させてコンテナイメージを作成していきます．  
そのため，Dockerfileから参照する`init.sh`を以下の内容で作成してください．  
このシェルスクリプトでは，

- MySQLの起動
- TERMシグナルが送られた場合に，MySQLを停止するように設定
- bashの起動

を行っています．

```
#!/bin/bash

service mysqld start

cat <<EOF >>~/.bashrc
trap 'service mysqld stop; exit 0' TERM
EOF
exec /bin/bash
```

### Dockerfileを作成

次にDockerfileを作成します．  
作成するDockerfileは以下の内容です．  
`MAINTAINER`は各自で適当に変更してください．  

```
FROM enakai00/centos:centos6
MAINTAINER s00t000

ENV HOME /root
RUN yum -y install mysql-server
ADD init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh

EXPOSE 3306
CMD ["/usr/local/bin/init.sh"]
```

`ENV`と`EXPOSE`は初めて出てきましたね．  
この2つに関して解説します．  
- `ENV`は，環境変数を設定するものです．例えば，以下のDockerfileでは`HOME`という環境変数に値として`/root`を設定しています．  
- `EXPOSE`は，コンテナ間のネットワークに晒すポートを指定します．  
  ポートを晒すことで他のコンテナから，そのコンテナへ接続することが可能になります．  
  なので，ここではMySQLが動く3306番ポートをネットワークに晒すことで，他のコンテナからこのコンテナのMySQLに接続できるようにしていることになります．  
  この`EXPOSE`の設定は[Node.jsアプリケーションのコンテナを起動](https://github.com/sai-lab/rookie-training/blob/docker/ContainerCooperation/docker/ContainerCooperation.md#nodejsアプリケーションのコンテナを起動)で生きてきます．

まとめると，Dockerfileでは

- 必要なパッケージのインストール
- 環境変数`HOME`に`/root`を設定
- `init.sh`のコンテナ内へのコピーと実行
- 3306番ポートをネットワークに晒す

といったことを行っています．

### MySQLのコンテナイメージを作成

これまでの手順でコンテナイメージ作成の準備が整いました．  
それでは以下のコマンドを実行してコンテナイメージを作成しましょう．

```
docker build -t vagrant/mysql:ver1.0 .
```

### MySQLのコンテナを起動

続けて，MySQLのコンテナを起動します．

```
docker run -itd --name mysql01 vagrant/mysql:ver1.0
```

### MySQLでDBとテーブル作成

最後に，このサービスで使うDBとテーブルを作成しておく必要があります．  
作業は起動したMySQLコンテナに入っての作業となります．  
コンテナに入るには以下のコマンドを実行します．  
`docker attach コンテナ名`で指定したコンテナのシェルに接続することができます．

```
docker attach mysql01
```

コンテナに入ったら，以下のコマンド群を実行します．  
このコマンド群は

- MySQLのユーザとして`nodeuser`を作成
- `nodeuser`のパスワード(ここでは`pas4mysql`)を設定
- DB`shorturl_service`の作成
- テーブル`url_list`の作成とそのカラム定義

といったことを行っています．

```
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nodeuser'@'localhost';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nodeuser'@'%' IDENTIFIED BY 'pas4mysql';"
mysql -u nodeuser -e "CREATE DATABASE shorturl_service;"
mysql shorturl_service -u nodeuser -e " \
CREATE TABLE url_list ( \
  hash CHAR(12) PRIMARY KEY, \
  url VARCHAR(256) UNIQUE NOT NULL COLLATE utf8_bin \
);"
```

#### MySQLでDBとテーブルの確認

念のため，上記の作業でDBとテーブルがしっかりと作成できているかを確認しましょう．  
確認には以下のコマンド群を実行します．  
下記コマンド群では上から順に，

- MySQLコマンドラインツールを起動
- DB一覧を表示
- DB`shorturl_service`の持つテーブル一覧を表示
- テーブル`url_list`に含まれるカラムの詳細表示

を行っています．  

```
mysql
show databases;
show tables from shorturl_service;
show columns from url_list from shorturl_service;
```

ここで確認したいのは，

- `show databases;`の実行結果に，`shorturl_service`が含まれているか
- `show tables from shorturl_service;`の実行結果に`url_list`が含まれているか
- `show columns from url_list from shorturl_service;`の実行結果に，`hash`カラム，`url`カラムが含まれているか

です．  
以上で問題なければ`Ctrl-D`を押してmysqlコマンドラインツールから抜けます．  
続いて，コンテナからデタッチしてホストマシンに戻るため，`Ctrl-P`，`Ctrl-Q`と続けて押下します．  

ここで`exit`コマンドを実行してしまうと，ホストマシンに戻ることはできますが，bashを終了させることになり，結果として**コンテナを停止**させてしまいます．  
コンテナを停止させてしまった場合は，以下のコマンドを実行してコンテナをもう一度起動してください．

```
docker start mysql01
```

ホストマシンに戻ることができたら，次の作業に進みましょう．

## Node.jsアプリケーションのコンテナ作成

続いて，Node.jsアプリケーションのコンテナを作成してきます．  

### Gitのインストール

ここでの作業でGitを使う部分があるため，始めにGitのインストールを行います．  
Gitのインストールには以下のコマンドを実行します．

```
sudo apt-get install git
```

### 必要なファイルをGitHubからクローンする

Dockerfileを含め，今回作成するNode.jsアプリケーションのコンテナイメージの作成に必要なファイルは，[Etsuji Nakai](https://github.com/enakai00)さんがGitHub上で公開してくださってるので，こちらを使います．  

以下のコマンドで必要なファイルをホームディレクトリにクローンします．

```
cd
git clone https://github.com/enakai00/build_shorturl
```

続いて，以下のコマンドを実行して，`~/build_shorturl`ディレクトリ内でブランチを`dockerbon`に切り替えます．  
以降，このディレクトリ内で作業をしていきます．

```
cd ~/build_shorturl
git checkout dockerbon
```

#### build_shorturl内の構成

因みにクローンしてきた`build_shorturl`内の構成は以下のようになっています．  
このうち，コンテナイメージを作るために必要になるのは，`Dockerfile`，`init.sh`，`app`ディレクトリです．  
`app`ディレクトリ下はNode.jsに関するコードなので触れませんが，`app/server.js`に関しては少しだけ触れます．  
また，`build_info`と`pre-commit`はGitと連携させる際に使うために用意されていますが，ここではGitと連携はしないので触れません．(消してしまってもOK)

```
build_shorturl/
├── app
│   ├── server.js
│   └── views
│       ├── index.ejs
│       └── result.ejs
├── build_info
├── Dockerfile
├── .dockerignore
├── init.sh
└── pre-commit
```

#### init.shの内容

この`init.sh`では，

- Node.jsの起動
- TERMシグナルが送られた場合に，Node.jsのプロセスを終了するように設定
- bashの起動

を行っています．

```
cd /root/app
node server.js &

cat <<EOF >>~/.bashrc
trap 'pkill -TERM node; sleep 3; exit 0' TERM
EOF
exec /bin/bash
```

#### Dockerfileの内容

`MAINTAINER`の部分は各自で適当なものに変更してください．  

このDockerfileでは以下のようなことを行っています．

- 必要なパッケージのインストール
- `/root/app`ディレクトリを作成し，ホストマシン上の`app`ディレクトリの中身を`/root/app`へコピー
- `init.sh`をコンテナへコピーし，実行
- 参照するDBの名前，ユーザ名，パスワードを環境変数として設定
- `node_modules`へのパスを環境変数として設定

```
FROM enakai00/centos:centos6
MAINTAINER s00t000

RUN yum -y install epel-release
RUN yum -y install nodejs nodejs-mysql nodejs-ejs nodejs-express
RUN mkdir /root/app
ADD app /root/app
ADD init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh

ENV NODE_DBNAME shorturl_service
ENV NODE_DBUSER nodeuser
ENV NODE_DBPASS pas4mysql
ENV NODE_PATH /usr/lib/node_modules

CMD ["/usr/local/bin/init.sh"]
```

#### app/server.jsの中身

`app/server.js`の最初の十数行ほどのところに以下のような記述があると思います．  
Node.jsでは`process.env.環境変数名`でそのマシン上の環境変数を取得することができます．  
以下に示すうち下3行は，上に示すDockerfileで定義した環境変数です．  
また上2行は，MySQLコンテナ`mysql01`のIPアドレスと，MySQLの動いているポート番号を取得しています．  
このMySQLコンテナ`mysql01`のIPアドレスとポート番号の環境変数がどのように定義されたかは，後述しています．([Node.jsアプリケーションのコンテナを起動](https://github.com/sai-lab/rookie-training/blob/docker/ContainerCooperation/docker/ContainerCooperation.md#nodejsアプリケーションのコンテナを起動)を参照)  
これらの環境変数を使って，Node.jsアプリケーションではMySQLコンテナ上で動くMySQLのDBにアクセスすることになります．

```
var DBHOST = process.env.DB_PORT_3306_TCP_ADDR;
var DBPORT = process.env.DB_PORT_3306_TCP_PORT;
var DBNAME = process.env.NODE_DBNAME;
var DBUSER = process.env.NODE_DBUSER;
var DBPASS = process.env.NODE_DBPASS;
```

### Node.jsアプリケーションのコンテナイメージを作成

それでは以下のコマンドを実行して，コンテナイメージを作成しましょう．

```
docker build -t vagrant/shorturl:ver1.0 .
```

### Node.jsアプリケーションのコンテナを起動

続いて，以下のコマンドよりコンテナを起動します．  
今回は今までと違い`--link mysql01:db`のように書かれていることに注意してください．

```
docker run -itd -p 8000:80 --link mysql01:db --name shorturl01 vagrant/shorturl:ver1.0
```

`--link mysql01:db`について解説します．  
これは簡単に言うと，先ほど起動したMySQLコンテナ`mysql01`とこのコンテナを結びつけるものです．  
形式は，`--link コンテナ名:エイリアス名`となっています．  
指定したコンテナで晒しているポート等の情報を，指定した**エイリアス名を大文字にして先頭**につけた環境変数を定義します．

ホストマシン上で以下のようなコマンドを実行してみてください．  
これはコンテナ`shorturl01`の環境変数を出力します．

```
docker exec shorturl01 env
```

コマンドを実行すると，以下のような環境変数が確認できるはずです．  
これらの環境変数で，コンテナ`mysql01`の持つIPアドレス，コンテナ`mysql01`のポート番号などを保持しています．  
まさに[app/server.jsの中身](https://github.com/sai-lab/rookie-training/blob/docker/ContainerCooperation/docker/ContainerCooperation.md#appserverjsの中身)では，この環境変数を利用しています．  
MySQLコンテナ`mysql01`のコンテナイメージを構築したDockerfileには`EXPOSE 3306`としてあり，3306番ポートをネットワークに晒しています．  
そのため，ここではMySQLコンテナ`mysql01`の3306番ポートの情報が環境変数として定義されています．

```
DB_PORT=tcp://172.17.0.4:3306
DB_PORT_3306_TCP_PORT=3306
DB_PORT_3306_TCP_PROTO=tcp
DB_PORT_3306_TCP_ADDR=172.17.0.4
DB_PORT_3306_TCP=tcp://172.17.0.4:3306
```

## Webページの確認

以上で2つのコンテナが起動しているはずです．  
Webページからアクセスして確認してみましょう．  
ブラウザで `http://133.92.147.245:10100`(10100は自分の番号に)  
にアクセスしてみてください．  

Webページへアクセス出来たら，何でもいいのでURLを入力して「短縮」を押してみましょう．  
すると遷移先のページに別のURLが表示されたと思います．  
そのURL先にアクセスすると，短縮前のURLにアクセスできたはずです．

## MySQLコンテナに入って確認

次にMySQLコンテナに入って，テーブルにデータが追加されているかを確認してみましょう．  
MySQLコンテナに入るには，以下のコマンドを実行します．

```
docker attach mysql01
```

MySQLコンテナに入ったら，以下のコマンドを実行して，テーブルにデータが追加されているか確認してみます．  
1つ目のコマンドは，利用するDBを指定して，MySQLコマンドラインツールを起動しています．  
2つ目のコマンドは，`url_list`テーブルの中身を表示します．

```
mysql -D shorturl_service
select * from url_list;
```

実行結果には，先ほどWebページでURLを入力して短縮URLを発行したときの，元のURLと短縮URLが表示されたと思います．  

テーブルの確認ができたら，`Ctrl-D`を押してmysqlから抜け，コンテナからデタッチしてホストマシンに戻ります．  
デタッチには，`Ctrl-P`，`Ctrl-Q`を続けて押下します．

---

次の付録 [appendix02 : コンテナ共有サイト Docker Hub](./Dockerhub.md) へ進む.  
[README](./README.md) に戻る．
