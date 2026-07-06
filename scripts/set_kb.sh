#!/usr/bin/env bash
#
# set_kb.sh — 记录「知识库根目录」，只需设置一次，之后所有技能自动读取、不再询问。
#
# 用法:  set_kb.sh <知识库绝对路径>
# 写入:  ${CLAUDE_PLUGIN_DATA:-~/.config/second-brain-plugin}/kb_path
#
# 说明：优先级低于环境变量 $SECOND_BRAIN_KB_PATH——若你导出了该环境变量，
# 它会覆盖这里记录的值（方便临时切换到另一个知识库）。
#
set -eu

if [ "$#" -lt 1 ]; then
  echo "用法: set_kb.sh <知识库绝对路径>" >&2
  exit 2
fi

KB="$1"
if [ ! -d "${KB}" ]; then
  echo "错误：目录不存在: ${KB}" >&2
  echo "请先创建该目录（哪怕是空目录），或检查路径是否写对，再重试。" >&2
  exit 1
fi

# 规整为绝对路径，避免记录相对路径导致后续解析歧义
KB="$(cd "${KB}" && pwd)"

CONFIG_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.config/second-brain-plugin}"
mkdir -p "${CONFIG_DIR}"
printf '%s\n' "${KB}" > "${CONFIG_DIR}/kb_path"

echo "已记录知识库位置：${KB}"
echo "（保存在 ${CONFIG_DIR}/kb_path，后续技能会自动读取，不再询问。）"
