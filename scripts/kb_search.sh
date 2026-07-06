#!/usr/bin/env bash
#
# kb_search.sh — 知识库结构化检索（不做 RAG）。
#
# 在 notes/ 与 _MOC/ 的 markdown 上按关键词 grep，汇总命中数并排序，
# 供 kb-weave 找相关旧条目、kb-ask 组装候选集。检索的是"已炼好的半成品"，
# 所以又快又准，不需要向量库。
#
# 知识库根目录由 resolve_kb.sh 解析（环境变量 / 配置文件），不写死任何本地路径。
#
# 用法:  kb_search.sh <关键词1> [关键词2 ...]
# 输出:  每行 "命中数<TAB>路径<TAB>标题"，按命中数降序；无匹配则提示。
#
# 兼容 macOS 自带 bash 3.2：不使用关联数组 / mapfile。
#
set -eu

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"

KB="$(bash "${SELF_DIR}/resolve_kb.sh")" || {
  echo "（知识库位置未配置，无法检索——请先设置知识库路径：scripts/set_kb.sh <路径>）" >&2
  exit 3
}

if [ "$#" -lt 1 ]; then
  echo "用法: kb_search.sh <关键词> [关键词...]" >&2
  exit 2
fi

RESULT=$(
  find "$KB/notes" "$KB/_MOC" -type f -name '*.md' 2>/dev/null | while IFS= read -r f; do
    c=0
    for kw in "$@"; do
      n=$(grep -io -F -- "$kw" "$f" 2>/dev/null | wc -l | tr -d ' ')
      n=${n:-0}
      c=$((c + n))
    done
    [ "$c" -gt 0 ] || continue
    title=$(sed -n 's/^title:[[:space:]]*//p' "$f" | head -1)
    [ -n "$title" ] || title=$(basename "$f")
    printf '%s\t%s\t%s\n' "$c" "$f" "$title"
  done | sort -rn
)

if [ -z "$RESULT" ]; then
  echo "（无匹配条目——可能是知识库尚空，或换个关键词再试）"
else
  echo "$RESULT"
fi
