# Docker#section05 : コンテナイメージの自動生成

sction03, sction04では公開されているDockerイメージを利用しました．  
次はDockerイメージ自体を作成してみましょう．  
Dockerイメージを作成するときにはDockerfileを作成します．

## Dockerfileの作成

Dockerfileは，自動的にDockerイメージを構築(build)する時に必要になるファイルです．  
イメージを構成する全ての要素を記述しておきます．

作業用ディレクトリを作成して移動します．

```
mkdir ~/mywhale
cd ~/mywhale
```

エディタで`Dockerfile`という名前のファイルを作成します．  
中身は以下のようにします．

```
FROM docker/whalesay:latest
RUN apt-get -y update && apt-get install -y fortunes
CMD /usr/games/fortune -a | cowsay
```

- `FROM` `RUN` `CMD`はイメージ構築時の命令です．
- `FROM`は構築時の元になるイメージを指定します．今回は先程と同じwhalesayを使います．
- `RUN`はコンテナ内でコマンドを実行します．[fortunes プログラム](https://ja.wikipedia.org/wiki/Fortune_(UNIX))をインストールします．
- `CMD`はコンテナ実行時にデフォルトで実行する命令です．

#### 実行するコマンド群

```
mkdir ~/mywhale
cd ~/mywhale
nano Dockerfile
```

## イメージの構築

イメージを構築するには`docker build`コマンドを使います．  
ここでは`docker build`コマンドで「docker-whale」イメージを作成します．

```
docker build -t docker-whale .
```

- `-t`は`イメージ名:タグ`を指定するオプションです．
- コマンドの最後に`.`が必要です．  
  カレントディレクトリをコンテキスト(イメージ内容)として指定し，  
  そこにあるDockerfileを使ってイメージの自動構築を命令します．

再び `docker images`コマンドを実行して，イメージが作成されているかどうかを確認します．

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker-whale        latest              2869f3029cd4        About a minute ago   274.9 MB
hello-world         latest              690ed74de00f        6 months ago         960 B
docker/whalesay     latest              6b362a9f73eb        10 months ago        247 MB
```

#### 実行するコマンド群

```
docker build -t docker-whale .
docker images
```

## 新しいイメージを実行

作成したイメージ`docker-whale`を使ってコンテナを実行します．   
セリフ長いな．

```
$ docker run docker-whale
____________________________________
/ Mr. Cole's Axiom:                  \
|                                    |
| The sum of the intelligence on the |
| planet is a constant; the          |
|                                    |
\ population is growing.             /
------------------------------------
   \
    \
     \     
                   ##        .            
             ## ## ##       ==            
          ## ## ## ##      ===            
      /""""""""""""""""___/ ===        
 ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
      \______ o          __/            
       \    \        __/             
         \____\______/   

```

- Dockerfileで指定したCMD命令で指定した`fortune`プログラムを実行し，  
  その結果をcowsayプログラムに渡しています．
- `fortune`プログラムは，この`docker-whale`イメージの中にあるものです．
- 実行するたびに`fortune`プログラムをコンテナの中で実行します．

#### 実行するコマンド群

```
docker run docker-whale
```

## イメージの詳細を確認

イメージの詳細を表示する`docker inspect`コマンドで，構築したイメージの情報を調べます．  
`Cmd`セクションが，先ほどCMD命令で指定したコマンドになっていることを確認します．

```
$ docker inspect docker-whale
（省略） "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) CMD [\"/bin/sh\" \"-c\" \"/usr/games/fortune -a | cowsay\"]"
```

この方法を使えば，それぞれのイメージがデフォルトでどのようなコマンドを実行するか，
実行前に確認できます．このほかにも，環境変数・ポート情報・ネットワーク・ボリュームに関する各種の情報が確認できます．

次はイメージの構築履歴を`docker history`コマンドで確認します．

```
$ docker history docker-whale
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
2869f3029cd4        21 minutes ago      /bin/sh -c #(nop) CMD ["/bin/sh" "-c" "/usr/g   0 B
dece11a04bd5        21 minutes ago      /bin/sh -c apt-get -y update && apt-get insta   27.82 MB
（省略）
```

1行がそれぞれDockerfileに記述した命令と対応しています．

#### 実行するコマンド群

```
docker inspect docker-whale
docker history dkcoer-whale
```

# 参考資料

- [Dockerのライフライクルを理解するハンズオン資料](http://qiita.com/zembutsu/items/d146295cfcf69c205c1e)  
  sction04と同様に，ほとんどここと同じです．  
  Qiitaのアカウントを持っていたら，いいねしておきましょう...!

---

次のセクション [section06 : コンテナのライフサイクル](./ContainerLifeCycle.md) へ進む.  
[README](./README.md) に戻る．
