# Docker#section02 : Dockerのインストール

## インストール

rookieサーバにログインして，以前作成したVMを起動してください．

```
cd ~/vagrant
vagrant up
vagrnat ssh
```

Dockerをインストールするためのシェルスクリプトが公開されているのでそれを使います.
Ubuntuだけかもしれません.要検証.

```
wget -qO- https://get.docker.com/ | sh
```

インストールが完了後，dockerを実行するユーザをdockerグループに追加します.

```
sudo usermod -aG docker vagrant
exit
vagrant ssh
```

Dockerを起動します.

```
sudo start docker
```

Dockerが起動していることを確認します．

```
sudo status docker
```

以下のように表示されていれば起動しています．

```
$sudo status docker
docker start/running, process 723
```

#### 実行するコマンド群
```
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker vagrant
sudo start docker
sudo status docker
```

---

次のセクション [section03 : 公開イメージの利用](./PublicImage.md) へ進む.
[README](./README.md) に戻る．
