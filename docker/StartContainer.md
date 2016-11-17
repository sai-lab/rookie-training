# Docker#section04 : コンテナの起動

## hello-world コンテナの実行

section03では，公開されているコンテナイメージの中でも完成している(?)ものを利用してコンテナを起動しました．

次は，おなじみのHello Worldを出力するコンテナを使ってみましょう．  
以下のコマンドを実行して，`hello-world`イメージを実行してください．

```
docker run hello-world
```

`supertest2014/nyan`を実行した時と同様，`hello-world`のダウンロードから始まります．  
初回実行時には，ローカル環境上に同名のイメージが無いか探します．  
なければDocker Hubから探し，自動的にダウンロードします．  
ダウンロード後，コンテナとしてイメージを実行しています．

もう一度`docker run hello-world`コマンドを実行します．  
今度がローカルにすでにイメージがあるので，ダウンロードせず，  
ローカルにあるイメージを使ってコンテナを起動します．

#### 実行するコマンド群

```
docker run hello-world
docker run hello-world
```

## イメージの確認と取得

ローカル環境上のイメージ一覧を確認するときは，`docker images`コマンドを使います．  
先程の「hello-world」イメージがダウンロード済みか確認します．

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB
```

次は，Docker Hubから`docker/whalesay`イメージをダウンロードします．  
ダウンロードするには`docker pull`コマンドを実行します．

```
docker pull docker/whalesay
```

これは`docker`ユーザの`whalesay`イメージを取得するという意味です．  
「ユーザ名/」が無い場合や「library/」と付く場合は公式イメージ(Docker社の精査済み)です．

再度`docker images`コマンドを実行し，`whalesay`イメージがローカルに存在することを確認します．

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB
docker/whalesay      latest              6b362a9f73eb        18 months ago       247 MB
```

このようにイメージがおいてある場所をリポジトリと呼びます．  
このリポジトリやイメージの詳細な情報はDocker Hub上でも確認できます．

- https://hub.docker.com/r/docker/whalesay/

#### 実行するコマンド群
```
docker images
docker pull docker/whalesay
dokcer images
```

## イメージの実行

`whalesay`イメージを使い，メッセージを表示するコンテナを実行しましょう．  
`whalesay`イメージが Ubuntu 14.04をベースに，`cowsay`という鯨がメッセージを表示するプログラムが入っています．  
ちなみに，鯨はdockerのマスコットキャラクター(?)です．

`docker`で`whalesay`イメージの中にある`cowsay`プログラムを実行します．
以下のように表示されると思います．

```
$ docker run docker/whalesay cowsay hello World
_____________
< hello world >
-------------
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


#### 実行するコマンド群

```
docker run docker/whalesay cowsay hello World
```

# 参考資料

- [Dockerのライフライクルを理解するハンズオン資料](http://qiita.com/zembutsu/items/d146295cfcf69c205c1e)
  ほとんどここと同じです．  
  Qiitaのアカウントを持っていたら，いいねしておきましょう...!

---

次のセクション [section05 : コンテナイメージの自動作成](./UseDockerfile.md) へ進む.  
[README](./README.md) に戻る．
