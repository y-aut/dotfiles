#!/usr/bin/env zsh
# ============================================================
#  エイリアス
# ============================================================

# ---- ls ----
alias ls='ls --color'
alias ll='ls -lh --color'
alias la='ls -ah --color'

# ---- git ----
alias g='git'
alias ga='g add'
alias gb='g branch'
alias gc='g commit'
alias gca='g commit --amend'
alias gcan='g commit --amend --no-edit'
alias gcl='g clone'
alias gco='g checkout'
alias gcob='g checkout -b'
alias gcp='g cherry-pick'
alias gd='g diff'
alias gdc='g diff --cached'
alias gf='g fetch'
alias gg='g grep'
alias ggf='g grep-file' # git/config で定義
alias gl='g log'
alias gm='g merge'
alias gp='g push'
alias gpl='g pull'
alias gr='g rebase'
alias gri='g rebase -i'
alias grp='g replace-all' # git/config で定義
alias grs='g reset'
alias grsh='g reset --hard'
alias grss='g reset --soft'
alias gs='g status'
alias gsm='g sync --merge' # git/config で定義
alias gsr='g sync --rebase' # git/config で定義
alias gst='g stash push -u'
alias gsta='g stash apply'
alias gstc='g stash clear'
alias gstd='g stash drop'
alias gstl='g stash list'
alias gstp='g stash pop'
alias gsw='g sweep' # git/config で定義
alias gswf='g sweep --force' # git/config で定義

# ---- docker ----
alias d='docker'
alias dc='d compose'
alias dcb='d compose build'
alias dcbn='d compose build --no-cache'
alias dcd='d compose down'
alias dcu='d compose up'
alias dcub='d compose up --build'
