#!/usr/bin/env bash
#
# resolve_kb.sh — 解析「知识库根目录」的绝对路径，供本插件所有技能/脚本复用。
#
# 解析顺序（先命中先用）：
#   1. 环境变量 $SECOND_BRAIN_KB_PATH（非空时优先）
#   2. 配置文件 ${CLAUDE_PLUGIN_DATA:-~/.config/second-brain-plugin}/kb_path
#   3. 都没有 → 退出码 3（"未配置"），调用方应引导用户运行 set_kb.sh 设置一次
#
# 成功时把知识库根目录路径打印到 stdout（单行）；失败信息走 stderr。
#
# 设计目的：插件是公开发布的，绝不能写死作者本地路径；每个使用者的知识库
# 在哪由他自己一次性设置，插件本身对此零知情。
#
set -eu

# 1) 环境变量优先
if [ -n "${SECOND_BRAIN_KB_PATH:-}" ]; then
  printf '%s\n' "${SECOND_BRAIN_KB_PATH}"
  exit 0
fi

# 2) 持久化配置文件
CONFIG_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.config/second-brain-plugin}"
CONFIG_FILE="${CONFIG_DIR}/kb_path"

if [ -f "${CONFIG_FILE}" ]; then
  path="$(head -1 "${CONFIG_FILE}" | tr -d '\n')"
  if [ -n "${path}" ]; then
    printf '%s\n' "${path}"
    exit 0
  fi
fi

# 3) 未配置
echo "知识库位置尚未配置。请让技能引导设置，或手动运行：" >&2
echo "  bash <plugin>/scripts/set_kb.sh <知识库绝对路径>" >&2
exit 3
