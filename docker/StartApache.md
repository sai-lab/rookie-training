# Docker#section07 : DockerでApacheを起動してみよう

次はApacheを起動するDockerイメージを作ってみましょう．

## Dockerfileの作成

作業用ディレクトリを作成して移動します．

```
mkdir ~/apache2
cd ~/apache2
```

`Dockerfile`を作成します．

中身は以下のようにします．

```
FROM ubuntu:14.04
MAINTAINER s00t000
RUN apt-get update && apt-get install -y apache2
ADD index.html /var/www/html/index.html
CMD service apache2 start && bash
```

- `FROM`ではベースとなり Ubuntu 14.04のイメージを指定しています．
- `MAINTAINER`にはDockerイメージの作成者名を指定します．  
  ここでは学籍番号を入れましょう．
- `RUN`ではapache2をインストールします．
- `ADD`では指定したファイルを指定したコンテナ内のディレクトリへコピーします．
  ここではindex.htmlを`/var/www/html/index.html`へコピーするように指示しています．
- `CMD`では`Apache2`を実行後，bashを起動するようにしています．

#### 実行するコマンド群

```
mkdir ~/apache2
cd ~/apache2
nano Dockerfile
```

## index.htmlの作成

コンテナ内に配置するindex.htmlファイルを作成します．  
以下のコマンドを実行して下さい．  
`s00t000`の部分は自分の学籍番号をいれてください．

```
echo "s00t000 says hello from Docker" > index.html
```

## Dockerfileを使ったコンテナイメージの作成

それでは，作成したDockerfileからコンテナイメージを作成します．  
`docker build`コマンドを実行します．


```
docker build -t vagrant/apache2:ver1.0 .
```

実行例を以下に示します．

```
$ docker build -t vagrant/apache2:ver1.0 .
Sending build context to Docker daemon 3.072 kB
Step 1 : FROM ubuntu:14.04
 ---> 1e0c3dd64ccd
...(中略)
Step 5 : CMD service apache2 start & bash
 ---> Running in a9132e596272
 ---> a92267bde908
Removing intermediate container a9132e596272
Successfully built a92267bde908
```

- Step1 ~ Step5の7つのステップが実行されていることが確認できます．
- 各ステップの実行後，ステップを実行したコンテナイメージを保存して，
  実行していたコンテナ(中間コンテナ)を破棄します．
- 次のステップでは，保存したコンテナイメージを起動して，ステップを実行 -> コンテナイメージ保存 -> コンテナ破棄 といった流れになります．

- Step3に当たる部分だけを編集して，再度buildした場合はStep2完了時点の中間イメージを利用して，以降の処理を行います．
- 中間イメージを利用しない場合は， `--no-cache`オプションを指定して実行します．

なるべくDockerfileを配置するディレクトリには，コンテナイメージに関係無いファイルは置かないようにしましょう．  
build実行後 `Sending build context to Docker daemon 3.072 kB` と出力されていますが，  
ここでは指定したディレクトリ内のすべてのファイルをコンテナ内に転送する処理を行っています．  
コンテナイメージに不要だけど，同じディレクトリに配置する必要のあるファイルがある時は，  
`.dockerignore`ファイルに記載しておくことで，転送対象から除外できます．

## ポートフォワードの設定

生成したコンテナを起動する前に，`Vagrantfile`をいじります．  

`exit`でVMから出た後，`vagrant halt`でVMを停止してください．

その後，エディタで`Vagrantfile`を編集してください．

コンテナ内のApacheへポートフォワードするために，既存のポートフォワードの設定を  
以下のように変更してください．10100のところは自分のポート番号にしてください．  
8000はそのままで問題ないです．

```
# config.vm.network :forwarded_port, guest: 80, host: 10100
config.vm.network :forwarded_port, guest: 8000, host: 10100
```

VMの80番ポートをそのままコンテナの80番ポートに転送したいところですが，  
VMの80番ポートはすでにVMのApacheが使っているため被ってエラーが出ます．

```
docker: Error response from daemon: driver failed programming external connectivity on endpoint web01 (fec51acddfa412f7eeb3767870f93af184ed908369d1b3d8e031f644e47bec31): Error starting userland proxy: listen tcp 0.0.0.0:80: bind: address already in use.
```

そのため，わかりづらいですが  
ホスト(Rookie):10100 -> VM(vagrant):8000 -> コンテナ:80  
というようにポートフォワードします．

編集が終わったら，`vagrant up`で再度VMを起動して，  
`vagrant ssh`でVMに接続してください．

## コンテナの起動

それでは，生成したイメージを利用してコンテナを起動しましょう．  
以下の通りに`docker run`コマンドを実行してください．

```
docker run -itd -p 8000:80 --name web01 vagrant/apache2:ver1.0
```

- `-t`オプションをつけることでコンテナ内の標準出力とホスト側の出力を繋げます．  
- `-i`オプションでホスト側の入力をコンテナ側の標準出力に繋げます．  
  とりあえず大体の場合は`-it`オプションをつけておけばOK！  
  わかりやすい解説はこちら-> [docker runのオプションについて](https://teratail.com/questions/19477)
- `-d`オプションをつけることでバックグラウンドでdockerを起動します．
- `-p`オプションでポートフォワードの設定を指定します．  
  `-p {ホストポート}:{コンテナポート}`というように形式．

実行しても謎の文字列が出力された後，そのままVMのシェルに戻ったと思います．  
念のため`docker ps`コマンドで起動しているか確認してみましょう.  
`-l`オプションをつけることで直近のpsだけ表示されます．

```
$ docker ps -l
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                  NAMES
66438f3c522e        vagrant/apache2:ver1.0   "/bin/sh -c 'service "   2 minutes ago       Up 2 minutes        0.0.0.0:8000->80/tcp   web02
```

## Webページの確認

Apacheのコンテナが起動したので，Webページがちゃんと表示されているのか確認してみましょう．  
ブラウザで `http://133.92.147.245:10100`(10100は自分の番号に)  
にアクセスして自分の書き込んだ文字列が表示されているか確認してみてください．

もしくは，VM上で`curl http://192.168.11.100:8000`で確認できます．

しっかり，表示されていると思います．

## アクセスログの確認

続いてApacheのアクセスログにちゃんとログが残っているか確認しましょう．  
`docker diff`コマンドを使うことで，コンテナ内で変更のあったディレクトリやファイルを確認することが出来ます．

```
$ docker diff web01
C /run
A /run/apache2
A /run/apache2/apache2.pid
C /run/lock
A /run/lock/apache2
C /tmp
C /var
C /var/log
C /var/log/apache2
C /var/log/apache2/access.log
C /var/log/apache2/error.log
```

- `A`が追加されたファイルです．
- `C`が変更されたファイルです．

`access.log`が変更されているのが確認できたので，実際に中身を見てみましょう．  
`docker cp`コマンドで，コンテナ内の指定したディレクトリ・ファイルを  
ホスト側にコピーすることができます．書式は以下の通りです．

`docker cp {コンテナ名}:{パス} {保存する名前}`

以下のコマンドを実行してください．

```
docker cp web01:/var/log/apache2 tmp
```

`access.log`を見てみましょう．

```
$ cat tmp/access.log
192.168.11.100 - - [17/Nov/2016:15:06:32 +0000] "GET / HTTP/1.1" 200 257 "-" "curl/7.35.0"
```

## コンテナイメージの保存

最後に，利用したコンテナを保存します．  
`docker commit`コマンドで指定したコンテナの複製をイメージとして保存できます．  
書式は以下の通りです．

`docker commit {コンテナ名} {保存後のコンテナ名}`

今回作成したコンテナ`web01`を`vagrant/apache2:ver1.1`として保存します．

```
docker commit web01 vagrant/apache2:ver1.1
```

保存後，起動したままの`web01`コンテナを停止します．

```
docker stop web01
```

不要になったコンテナは`docker rm`コマンドで削除できます．

```
docker rm web01
```

同様に，不要になったイメージは`docker rmi`コマンドで削除できます．

```
docker rmi vagrant/apache2:ver1.0
```

---

次のセクション [section08 : Dockerfileとシェルスクリプトの連携](./ShellCooperation.md) へ進む.  
[README](./README.md) に戻る．
