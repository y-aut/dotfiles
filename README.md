# dotfiles

zsh / git の共有設定。

## 設計：2層構成

| レイヤ | 場所 | 内容 | Git |
|---|---|---|---|
| 共有 | このリポジトリ | どのマシンでも同じ設定 | 管理する |
| マシン固有 | `~/.zshrc` / `~/.gitconfig` | PATH、証明書、`user.email`、秘密情報 | 管理しない |

`~/.zshrc` は **symlink にしない**。実ファイルのまま残し、その先頭から
このリポジトリの `zsh/zshrc` を `source` する。

この向きにしている理由:

- Rancher Desktop、SDKMAN、nvm などのインストーラは `~/.zshrc` に自動追記する。
  `~/.zshrc` をマシン固有レイヤにしておけば、その追記は本来属するべき場所に
  自然に着地し、共有リポジトリに混入する経路が存在しない。
- macOS の `sed -i` は一時ファイル + rename で実装されているため、symlink に
  対して実行するとリンクが壊れて通常ファイルに置き換わる。実ファイルなら
  この事故が起きない。

`source` するのは先頭。インストーラは末尾に追記するので、先頭だけが
「共有が先、マシン固有が後」という関係を恒久的に保てる位置になる。

## 新しい Mac での手順

clone 先はどこでもよい（インストーラが自分の位置を解決する）。

```sh
git clone <repo-url> ~/programs/personal/dotfiles
cd ~/programs/personal/dotfiles
./install.sh --dry-run   # 変更内容を確認
./install.sh
exec zsh
```

マシン固有の設定（業務用の PATH、社内証明書など）は clone 後に
`~/.zshrc` の下部へ手で書く。

## 構成

```
install.sh      ~/.zshrc と ~/.gitconfig に読み込み設定を追記する
zsh/zshrc       共有 zsh 設定の本体
zsh/prompt.zsh  git 状態を表示するプロンプト
zsh/aliases.zsh ls / git / docker のエイリアス
git/config      git alias（grep-file, replace-all, sync）
```

## 注意点

- **`compinit` は共有側の冒頭で走る。** `~/.zshrc` 側で `fpath` に補完定義を
  追加しても読み込まれないので、その場合は追加行の直後に `compinit` を
  書き足す。
- **`mise activate` は共有側の末尾で走る。** その後に `~/.zshrc` 側で PATH を
  前置すると mise のシムが押し下げられる。mise で入れたバージョンが効かない
  場合は `eval "$(mise activate zsh)"` だけを `~/.zshrc` の末尾に移す。
- **`~/.gitconfig` の include は末尾に追加される。** git は後勝ちなので、
  同じキーを両方で設定すると共有側が勝つ。現状 `git/config` は alias のみ
  なので衝突しない。
- **秘密情報をこのリポジトリに入れない。** API キーやトークンは `~/.zshrc`
  側に置く。コミット前に `git diff` を確認する。
