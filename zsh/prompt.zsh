#!/usr/bin/env zsh
# ============================================================
#  プロンプト
#
#  git リポジトリ内では、ブランチ名（または detached HEAD）、
#  マージ・リベース等の進行状態、変更ファイル数を表示する。
#      <branch> (<tracked> / <untracked>)
# ============================================================

git_prompt() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local ref
    if [[ -n "$branch" ]]; then
      ref="%F{2}${branch}%f"
    else
      local hash=$(git rev-parse --short HEAD 2>/dev/null)
      ref="%F{1}detached HEAD at ${hash}%f"
    fi

    local state=""
    local gitdir=$(git rev-parse --git-dir 2>/dev/null)
    if [[ -f "${gitdir}/MERGE_HEAD" ]]; then
      state=" MERGING"
    elif [[ -d "${gitdir}/rebase-merge" ]]; then
      state=" REBASE"
    elif [[ -f "${gitdir}/CHERRY_PICK_HEAD" ]]; then
      state=" CHERRY-PICKING"
    elif [[ -f "${gitdir}/REVERT_HEAD" ]]; then
      state=" REVERTING"
    elif [[ -f "${gitdir}/BISECT_LOG" ]]; then
      state=" BISECTING"
    fi

    local tracked=$(git status --porcelain | grep '^[ MARCUD]' | grep -v '^??' | wc -l | tr -d ' ')
    local untracked=$(git status --porcelain | grep '^??' | wc -l | tr -d ' ')
    echo "\n${ref}%F{1}${state}%f (%F{3}${tracked}%f / %F{8}${untracked}%f)"
  fi
}

setopt prompt_subst

PROMPT='$(git_prompt)
%F{8}%n@%m%f %F{4}%~ $%f '
