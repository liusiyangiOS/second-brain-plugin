#!/usr/bin/env bash
#
# commit_kb.sh — 只暂存并提交「本次归档到知识库的文件」，然后推送到远端。
#
# 设计目的：知识库所在仓库（AboutAI）随时可能有其它未提交的无关改动。
# 本脚本绝不使用 `git add -A` / `git add .`，只精确暂存传入的文件路径，
# 避免把用户遗留的无关改动一起提交上去。
#
# 用法:
#   commit_kb.sh "<commit message>" <file1> [file2 ...]
#
# 示例:
#   commit_kb.sh "docs(知识库): 归档 Claude Code 子代理编排方法到 技术分享" \
#     "/Users/liusiyang/Documents/GitHubOfMine/AboutAI/知识库/技术分享/2026-07-05-子代理编排.md"
#
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "用法: commit_kb.sh \"<commit message>\" <file1> [file2 ...]" >&2
  exit 2
fi

MSG="$1"; shift
FILES=("$@")

# 校验文件存在，并从第一个文件推断仓库根目录
for f in "${FILES[@]}"; do
  if [ ! -e "$f" ]; then
    echo "错误：文件不存在: $f" >&2
    exit 1
  fi
done

FIRST_DIR="$(cd "$(dirname "${FILES[0]}")" && pwd)"
REPO="$(git -C "$FIRST_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO" ]; then
  echo "错误：目标路径不在任何 git 仓库内: ${FILES[0]}" >&2
  exit 1
fi

echo "== 仓库根: $REPO"
echo "== 分支:   $(git -C "$REPO" branch --show-current)"

# 只暂存本次归档文件（-- 之后全部按路径处理，杜绝误伤）
git -C "$REPO" add -- "${FILES[@]}"

echo
echo "== 本次将提交的改动（仅归档文件）=="
git -C "$REPO" diff --cached --stat

# 若没有任何实际暂存内容（例如文件与 HEAD 完全一致），提前退出
if git -C "$REPO" diff --cached --quiet; then
  echo "没有需要提交的变更（归档文件与仓库中现有内容一致）。已跳过提交与推送。"
  exit 0
fi

echo
echo "== 仓库内其它未提交改动（保持不动，不会被提交）=="
git -C "$REPO" status --short -- . ':(exclude)'"${FILES[0]}" 2>/dev/null | grep -v '^A ' || echo "（无 / 仅本次归档文件）"

git -C "$REPO" commit -m "$MSG"

echo
echo "== 推送到远端 =="
BRANCH="$(git -C "$REPO" branch --show-current)"
if git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
  git -C "$REPO" push
else
  echo "当前分支未设置 upstream，使用 origin ${BRANCH}。"
  git -C "$REPO" push -u origin "${BRANCH}"
fi

echo
echo "== 完成。最新提交 =="
git -C "$REPO" log -1 --stat
