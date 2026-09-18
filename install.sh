#!/usr/bin/env bash
# ============================================================
#  dotfiles インストーラ
#
#  やること:
#    1. ~/.zshrc の先頭に、共有 zshrc を source するブロックを追記
#    2. ~/.gitconfig に、共有 git config を include する設定を追加
#
#  ~/.zshrc と ~/.gitconfig は「マシン固有レイヤ」なので、
#  このリポジトリでは管理しない。書き換える前にバックアップを取る。
#
#  使い方:
#    ./install.sh            実行
#    ./install.sh --dry-run  変更内容を表示するだけ（何も書き換えない）
# ============================================================
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=true

# このスクリプト自身の位置を実体パスで解決する。
# これにより clone 先がどこでも動く（ルートに置く必要がない）。
DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"

# $HOME 配下なら $HOME 表記で書き出す。
# Mac 間でユーザ名が違っても壊れないようにするため。
DOTFILES_LITERAL="${DOTFILES/#$HOME/\$HOME}"

ZSHRC="$HOME/.zshrc"
MARKER_START="# >>> dotfiles >>>"
MARKER_END="# <<< dotfiles <<<"

BLOCK=$(printf '%s\n' \
  "$MARKER_START" \
  "export DOTFILES=\"$DOTFILES_LITERAL\"" \
  '[[ -r "$DOTFILES/zsh/zshrc" ]] && source "$DOTFILES/zsh/zshrc"' \
  "$MARKER_END" \
  "")

echo "dotfiles: $DOTFILES"
$DRY_RUN && echo "(dry-run: 何も書き換えません)"
echo

# ------------------------------------------------------------
# 1. ~/.zshrc
# ------------------------------------------------------------
if [[ -L "$ZSHRC" ]]; then
  echo "中止: $ZSHRC が symlink です。この構成では実ファイルを想定しています。" >&2
  echo "      手動で確認してください。" >&2
  exit 1
fi

if grep -qF "$MARKER_START" "$ZSHRC" 2>/dev/null; then
  echo "[zsh]  skip: 既に導入済みです"
else
  echo "[zsh]  $ZSHRC の先頭に以下を追記します:"
  echo "$BLOCK" | sed 's/^/         | /'
  if ! $DRY_RUN; then
    if [[ -f "$ZSHRC" ]]; then
      backup="$ZSHRC.bak.$(date +%Y%m%d%H%M%S)"
      cp "$ZSHRC" "$backup"
      echo "[zsh]  backup: $backup"
    fi
    tmp="$(mktemp)"
    {
      echo "$BLOCK"
      [[ -f "$ZSHRC" ]] && cat "$ZSHRC"
    } > "$tmp"
    mv "$tmp" "$ZSHRC"
    echo "[zsh]  done"
  fi
fi
echo

# ------------------------------------------------------------
# 2. ~/.gitconfig
# ------------------------------------------------------------
if git config --global --get-all include.path 2>/dev/null | grep -qxF "$DOTFILES/git/config"; then
  echo "[git]  skip: 既に include 済みです"
else
  echo "[git]  include.path に $DOTFILES/git/config を追加します"
  if ! $DRY_RUN; then
    gitconfig="${GIT_CONFIG_GLOBAL:-$HOME/.gitconfig}"
    if [[ -f "$gitconfig" ]]; then
      backup="$gitconfig.bak.$(date +%Y%m%d%H%M%S)"
      cp "$gitconfig" "$backup"
      echo "[git]  backup: $backup"
    fi
    git config --global --add include.path "$DOTFILES/git/config"
    echo "[git]  done"
  fi
fi
echo

if ! $DRY_RUN; then
  echo "完了しました。新しいシェルを開いて確認してください:"
  echo "  exec zsh"
fi
