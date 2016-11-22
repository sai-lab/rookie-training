# Vagrant#section02 : Vagrantとは

仮想マシンを使って開発することでホストマシンを汚さずに，  
クリーンな環境で開発できることをsection01では紹介しました．

このように仮想マシンは，開発する上でできるだけ使いたいものですが，  
一つだけ欠点があります．

それは構築するのがめんどくさいということです．

仮想マシンを作成するためのソフトウェアに  

- Oracle VirtualBox
- VMware
- Xen
- KVM

などがあります．

[appendix01 : 仮想化ソフトウェアの種類](./SoftwareType.md)で詳しく説明しますが，  
どれも構築するのが結構めんどうだったり，専門知識が求められたりすることが共通しています．  

この問題点を解決することができるツールがVagrantです．

Vagrantは，`Vagrantfile`という構築手順が書かれたファイルを使って実行するだけで，  
自動で仮想環境を構築してくれる仮想マシンのラッパーツールです．

Vagrantを使うことで，簡単に仮想環境を構築できる上に，  
チームメンバで作業環境を統一することができます．  
設定ファイルだけ共有しておけば，それに従って起動するだけなので  
とても簡単です．

[Vagrant](https://www.vagrantup.com/)は，[HashiCorp](https://www.hashicorp.com/)社が開発している仮想環境を構築するためのオープンソースソフトウェアです．

Ruby製のソフトウェアで，[Oracle VirtualBox](https://www.virtualbox.org/)や[KVM](http://www.linux-kvm.org/page/Main_Page)などの仮想化ソフトウェアに対応しています．

説明はこんな感じにして実際にVagrantを使ってみましょう．

---

次のセクション [section03 : ](./StartVagrant.md) へ進む.  
[README](./README.md) に戻る．
