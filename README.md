# 第二大脑 · 个人知识库工具（second-brain-plugin）

一个把「AI 生成的内容」沉淀成「可复利的个人知识网」的 Claude Code 插件。

它的立场很明确：**知识是反复加工、彼此连接之后的产物，不是原始信息的堆叠。** 所以这套工具不做 RAG——不把原料丢进向量库现查，而是**在入库时就把算力前置**：把材料炼成原子笔记、建立双向链接、更新领域地图（MOC）。提问时只需读「地图 + 少量相关笔记」，又快又准，且越用越聪明。

## 设计理念

- **半成品优先，不做 RAG**：入库即炼成原子笔记（TL;DR + 核心论断 + 你的疑问与发散），提问时只读半成品，不做向量检索。
- **入库必编织**：每条新知识都要长进已有的网——找相关旧条目、建双向链接、更新 MOC，必要时回头修订旧条目。这是复利的来源。
- **沉淀疑问，不只沉淀结论**：你当时没懂的点、追问、发散，和结论一样值钱，一并留下。
- **git-native + Claude-native**：知识库就是一堆 markdown + 约定，Claude 本身就是检索与编织引擎，不依赖任何 GUI 应用。

## 组成

| 名称 | 类型 | 作用 |
|------|------|------|
| `kb-digest` | skill | 给链接/材料 → 先讲解总结（不入库）→ 承接你的追问发散 → 消化后炼成原子笔记入库 |
| `kb-weave` | skill | 入库即编入知识网：双向链接、更新 MOC、回改旧条目（复利引擎） |
| `kb-ask` | skill | 基于炼好的半成品快速问答，不做 RAG，答案溯源到具体笔记 |
| `organize-to-knowledge-base` | skill | 底层原语：整篇成品分类落盘 + 只提交本次文件后推送 |
| `kb-librarian` | agent | 整库重活：巡检死链、补全双链、合并重复、批量更新 MOC |

底层脚本：`commit_kb.sh`（只暂存本次文件的安全提交，绝不 `git add -A`）、`kb_search.sh`（结构化检索，非 RAG）。

## 安装

```
/plugin marketplace add https://github.com/liusiyangiOS/second-brain-plugin
/plugin install second-brain-plugin@second-brain
```

或先 `git clone` 到本地后用本地路径添加：

```
/plugin marketplace add /path/to/second-brain-plugin
/plugin install second-brain-plugin@second-brain
```

## 配置（他人使用需改一处）

知识库**数据目录**目前写死为作者本地路径 `/Users/liusiyang/Documents/GitHubOfMine/AboutAI/知识库`。若你要用于自己的知识库，改这两处指向你自己的知识库目录即可：

- 各 skill / agent 里作为「约定事实源」引用的 `知识库/README.md` 路径；
- `skills/organize-to-knowledge-base/scripts/kb_search.sh` 顶部的 `KB=` 默认值。

插件内部脚本之间的引用用的是官方注入的 `${CLAUDE_PLUGIN_ROOT}`，跟随安装位置自动解析，无需改动。

## 知识库结构约定

```
知识库/
├── _MOC/            # 领域地图（知识网枢纽，随新笔记不断生长）
├── notes/           # 原子笔记：一条一个概念，frontmatter 双链
├── 技术分享/ 临时想法/ …   # 成品 / 归档分类目录
└── README.md        # 约定唯一事实源
```
