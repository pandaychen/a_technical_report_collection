# ebpf-net-viz TCP 重传监控博客 翻译总结 技术对话记录

> 日期：2026-06-12
> 会话主题：Israel Ogbole 博客「Getting Started with eBPF: Monitoring TCP Retransmissions Using eBPF, Go and Prometheus」翻译与总结
> 参与方：用户 + Cursor Agent

---

## 会话概要

用户提供了 Israel Ogbole 的 eBPF 入门博客链接（<https://israelo.io/blog/ebpf-net-viz/>），要求翻译并总结。Agent 先抓取原文全文（约 477 行 Markdown），再通过 GitHub API 获取了配套项目 `iogbole/ebpf-network-viz` 的 `src/main.go` 与 `src/ebpf/retrans.c` 源码以核对细节，最终产出一份中文翻译+技术深化文档：包含 mermaid 架构图、内核态/用户态代码逐段解析、独立技术评价（含 8 项生产化必修补清单与 5 个同类开源方案对比表），并按项目规则将本次对话独立归档。

## 使用的工具/Skills

- WebFetch：抓取原文 HTML 与 GitHub raw 源码
- Read：参考已有翻译文档（`ebpf-dns-monitoring-翻译与总结-20260611.md`）与项目规则、`save-qa-record` skill
- TodoWrite：跟踪两项主任务

---

## 详细对话记录

### Q1: 翻译并总结 ebpf-net-viz 文章

**用户提问：**
> <https://israelo.io/blog/ebpf-net-viz/>
> 翻译和总结这篇文章

**分析过程：**

1. WebFetch 获取原文（10/12/2023 发布，作者 Israel Ogbole，文章 477 行）
2. 通过 GitHub API 列出仓库结构，确认核心文件：
   - `src/main.go`（用户态 Go 程序）
   - `src/ebpf/retrans.c`（内核态 eBPF C 程序）
   - `create_tcp_chaos.sh`、`run_prom.sh`、`prometheus.yml`
3. 拉取 `main.go` 与 `retrans.c` 全文，对照原文章节做技术核对，发现：
   - 文章中 `bpf_perf_event_output` 用 `__u32 key = 0;` 硬编码 CPU0，存在多核场景隐患
   - Go 端 IPv6 格式化函数不规范（应该用 `net.IP(buf[:]).String()`）
   - Prometheus label 五元组全入 cardinality 风险高
   - 没有处理 perf `LostSamples`
4. 参考项目内已有翻译文档（`ebpf-dns-monitoring-翻译与总结-20260611.md`）的排版风格——分章节、mermaid 架构图、独立技术评价、与同类开源方案对比
5. 撰写完整翻译总结文档，覆盖：
   - 文章定位与摘要
   - 为什么关注 TCP 重传 / 为什么用 eBPF
   - 端到端数据流（mermaid）
   - 内核态 C 代码剖析（含 BPF CO-RE、tracepoint ctx、PERF_EVENT_ARRAY、`bpf_ktime_get_ns` / `bpf_get_current_pid_tgid` 用法）
   - 用户态 Go 程序剖析（cilium/ebpf、perf reader、Prometheus 集成）
   - Prometheus + tc/netem 故障注入闭环
   - 独立技术评价：8 项生产化必修补 + 5 套同类方案对比（bcc tcpretrans、Cilium Hubble、DeepFlow/Pixie、node_exporter、Tetragon）
   - 复现指南（mermaid 流程图）

**结论/输出：**

产出文档 `ebpf/ebpf-net-viz-tcp-retransmissions-翻译与总结-20260612.md`，核心结论：

1. **文章定位**：eBPF 入门级最小可运行 demo（tracepoint + perf event array + Go + Prometheus），适合"第一个 eBPF 网络项目"模板
2. **挂载点**：`tracepoint/tcp/tcp_retransmit_skb`，ABI 稳定、跨内核兼容好
3. **生产化注意点**：原文代码在多核 CPU key 硬编码、IPv6 格式化、cardinality 控制、Lost 事件处理、ringbuf vs perf array 等方面均存在改进空间
4. **生产推荐**：临时排障用 `bpftrace tcpretrans`；持续节点级用 node_exporter；带五元组维度需自研可参考本文；K8s 生产环境直接上 Cilium Hubble / DeepFlow
5. **告警阈值**：作者推荐 2% 重传率作为告警阈值（与 Datadog/New Relic 默认值一致）

---

## 生成的产物清单

| # | 文件名 | 类型 | 说明 |
|---|--------|------|------|
| 1 | `ebpf/ebpf-net-viz-tcp-retransmissions-翻译与总结-20260612.md` | 文档 | 原文翻译 + 技术深化 + 独立评价 |
| 2 | `transcript/qa-20260612-ebpf-net-viz-tcp-retransmissions翻译总结.md` | 记录 | 本次对话记录 |

## 后续待办

- [ ] 如果用户后续想做生产化改造，可基于「§8.2 必修补清单」逐项重写为带 bpf2go + ringbuf + 受控 cardinality 的版本
- [ ] 可考虑补充一个对照 demo：用 `bpf2go` 重写本项目，生成的 Go 端结构体自动对齐，对比改造前后的可维护性
- [ ] 如需在 K8s 集群验证此类 eBPF 监控，建议下一步研究 Cilium Hubble 或 DeepFlow 的 retransmit 指标采集机制
