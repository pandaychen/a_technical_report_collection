# eBPF-Guide 中文翻译 — 技术对话记录

> 日期：2026-06-11
> 会话主题：翻译 GitHub 仓库 mikeroyal/eBPF-Guide 的 README 文档
> 参与方：用户 + Claude Code

---

## 会话概要

用户请求将 [mikeroyal/eBPF-Guide](https://github.com/mikeroyal/eBPF-Guide) 仓库的 eBPF 指南文档翻译为中文。该仓库是一份面向 eBPF 开发者的资源索引，涵盖 eBPF 工具/库、LLVM/Go/C++/Rust 开发生态、网络、Kubernetes 与数据库等章节。

本次会话完成了全文中文翻译，并保存至项目 `ebpf/` 目录。翻译策略为：忠于原文结构与条目顺序；对 eBPF 核心工具与概念做完整中文释义；对学习资源类纯链接列表保留英文条目并附简短中文说明；网络分层与协议部分补充表格以便阅读。

---

## 使用的工具/Skills

- 用户上传的原文快照：`uploads/eBPF-Guide-0.md`
- 项目内既有翻译文档格式参考：`ebpf/the-art-of-writing-ebpf-programs-a-primer-翻译与总结-20260326.md`

---

## Q&A 记录

### Q1：帮我翻译这篇 eBPF 文档

**用户问题：**

> https://github.com/mikeroyal/eBPF-Guide
> 帮我翻译这篇 ebpf 的文档

**处理过程：**

1. 读取用户上传的原文快照（GitHub 页面抓取内容，约 1200+ 行）
2. 对照项目既有翻译文档格式，确定输出路径与命名规范
3. 按原文 8 大章节逐段翻译：
   - 一、eBPF 入门（工具与库、书籍与教程）
   - 二、LLVM 开发
   - 三、Go 开发
   - 四、C/C++ 开发
   - 五、Rust 开发
   - 六、网络（含 OSI/TCP-IP 分层与协议详解）
   - 七、Kubernetes
   - 八、数据库
4. 补充贡献说明与 CC BY 4.0 许可证信息

**交付物：**

- 翻译文档：`ebpf/ebpf-guide-mikeroyal-翻译-20260611.md`
- 本对话记录：`transcript/qa-20260611-ebpf-guide-mikeroyal-翻译.md`

---

## 文档结构说明

| 章节 | 内容要点 |
|------|----------|
| eBPF 入门 | 60+ 个 eBPF 工具/库/框架的中文释义（Cilium、Falco、Tracee、Tetragon、libbpf 等） |
| LLVM/Go/C++/Rust | 各语言学习资源链接 + 工具框架简介 |
| 网络 | 基础概念、OSI 7 层、TCP/IP 4 层、MAC/IP/TCP/UDP/HTTP/DNS/SSH 等协议 |
| Kubernetes | 40+ 个 K8s 生态工具与托管服务 |
| 数据库 | SQL/NoSQL 学习资源 + 主流数据库与 BI 工具 |

---

## 备注

- 原文为资源索引型文档，非深度技术教程；翻译以「准确传达各条目含义」为主，未对链接做逐一验证。
- 原文中部分图片（如 eBPF.io、Microsoft、Brendan Gregg 的 BCC 图）在抓取文本中未包含图片本体，翻译文档中以文字标注图源。
- 若需进一步加工，可在此基础上增加：eBPF 工具分类思维导图（mermaid）、与 Tracee/Tetragon/Falco 的对比表、或按「安全/网络/可观测性」重新编排索引。
