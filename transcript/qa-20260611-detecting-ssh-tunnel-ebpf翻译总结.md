# Detecting SSH Tunnel Using eBPF 翻译总结 技术对话记录

> 日期：2026-06-11
> 会话主题：Medium 文章「Detecting SSH Tunnel Using eBPF」翻译与总结
> 参与方：用户 + Cursor Agent

---

## 会话概要

用户提供了 Medium 文章链接，要求翻译并总结这篇关于使用 eBPF 检测 SSH 隧道的技术文档。分析过程中获取了原文全文，并定位了对应的 GitHub 开源项目（eBPF-Detect-SSH-Tunnels / sshtunnel）。本文是姊妹篇「Tracing SSH User Activities Using eBPF」（sshtrace）的配套文章，聚焦 sshd 侧隧道检测而非命令归因。最终产出了一份包含原文翻译、技术方案解析、mermaid 架构图、实验复现步骤和技术评价的完整中文文档。

## 使用的工具/Skills

- WebFetch：获取 Medium 原文内容
- WebSearch：查找文章对应的 GitHub 项目信息
- Read：参考已有翻译文档格式（tracing-ssh-user-activities 系列）

---

## 详细对话记录

### Q1: Detecting SSH Tunnel Using eBPF 翻译与总结

**用户提问：**
> https://medium.com/etracing/detecting-ssh-tunnel-using-ebpf-29e73b21133e
> 翻译并总结这份文档

**分析过程：**

1. WebFetch 获取 Medium 原文全文
2. WebSearch 定位 GitHub 项目：`qjawls2003/eBPF-Detect-SSH-Tunnels`（sshtunnel）
3. 参考项目内姊妹篇翻译文档格式（`tracing-ssh-user-activities-ebpf-翻译与总结-20260611.md`）
4. 提炼核心技术方案：getpeername tracepoint 记录初始 SSH 连接 + connect tracepoint 通过 PPID 查表判定隧道
5. 绘制 mermaid 架构图和隧道检测时序图
6. 撰写技术评价（优点、局限、与 sshtrace 对比）

**结论/输出：**

产出文档 `ebpf/detecting-ssh-tunnel-using-ebpf-翻译与总结-20260611.md`，核心要点：

1. **威胁模型**：SSH 隧道用于绕过防火墙、混淆来源、构建代理链
2. **关键发现**：sshd 在隧道实际使用时调用 connect，且与初始 SSH 连接在同一进程树（通过 PPID 关联）
3. **检测算法**：getpeername 时将 sshd PID → socket 写入 BPF map；connect 时用 PPID 查表，命中则判定为隧道
4. **输出**：初始 SSH 来源 IP:port + 隧道目标 IP:port，日志写入 `/var/log/sshtunnel.log`
5. **附加功能**：客户端侧 SSH 命令参数检测（-L/-R/-D）

---

## 生成的产物清单

| # | 文件名 | 类型 | 说明 |
|---|--------|------|------|
| 1 | `ebpf/detecting-ssh-tunnel-using-ebpf-翻译与总结-20260611.md` | 文档 | 原文翻译与技术总结 |
| 2 | `transcript/qa-20260611-detecting-ssh-tunnel-ebpf翻译总结.md` | 记录 | 本次对话记录 |

## 后续待办

- [ ] 可进一步分析 sshtunnel 源码做深度代码走读
- [ ] 与 sshtrace 源码对比，梳理共享的 libbpf 基础设施
- [ ] 评估在 Tetragon/Falco 中实现同等检测规则的可行性
