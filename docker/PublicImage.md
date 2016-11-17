# Docker#section03 : 公開イメージの利用

インストールしていきなりですが，[Docker Hub](https://hub.docker.com/)で公開されているコンテナイメージを利用してみましょう．

Docker Hubについては[appendix02 : Docker Hub](./Dockerhub.md)で詳しく説明する予定です．  
Githubで多くのユーザがコードを公開しているように，  
Docker Hubでは様々なコンテナイメージが公開されています．

Dockerの便利さを手っ取り早く実感するために，試しにとある公開イメージを使ってコンテナを起動します．

`~/docker`というディレクトリを作成して移動してください．

```
mkdir ~/docker && cd ~/docker
```

移動後，`supertest2014/nyan`という公開されているイメージを使ってコンテナを実行します．  
コンテナを実行するには，`docker run` コマンドを使います．書式は以下の通りです．

`docker run <オプション> イメージ名:タグ <コマンド>`

ここでは，以下のように実行してください．

```
docker run -it --rm supertest2014/nyan
```

実行できましたか？  
飽きたら`Ctrl-c`を打ってコンテナを停止してください．

`--rm`オプションをつけてコンテナを起動すると，コンテナが停止すると同時に自動的にコンテナが破棄されます．

簡単な例ですが，`docker run`コマンドだけでDocker Hub上に公開されている  
さまざまなアプリケーション(コンテナイメージ)を自由に実行できることがわかります．  
実行環境と実行するアプリケーションをセットで管理しているため，このように非常に簡単に実行することができます．

#### 実行するコマンド群
```
mkdir ~/nyan && cd ~/nyan
docker run -it --rm supertest2014/nyan
```

# 参考資料

- [Docker実践入門](http://gihyo.jp/book/2015/978-4-7741-7654-3)
  - ほとんどここから引用．
- [Dockerのライフライクルを理解するハンズオン資料](http://qiita.com/zembutsu/items/d146295cfcf69c205c1e)

---

次のセクション [section04 : コンテナの起動](./StartContainer.md) へ進む.  
[README](./README.md) に戻る．
