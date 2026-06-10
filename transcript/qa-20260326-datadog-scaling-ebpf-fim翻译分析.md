# QA 记录：Datadog eBPF FIM 大规模实践翻译与分析

> 日期：2026-03-26
> 原文：[Scaling real-time file monitoring with eBPF](https://www.datadoghq.com/blog/engineering/workload-protection-ebpf-fim/)

## 问题

翻译并总结 Datadog 关于使用 eBPF 构建大规模文件完整性监控系统的工程实践文章。

## 回答

已完成翻译与深度分析，文档保存于 `ebpf/datadog-scaling-ebpf-fim-翻译与分析-20260326.md`。核心内容：Datadog 基础设施每分钟产生 100 亿+ 文件相关事件，通过 Approver（静态白名单）+ Discarder（动态黑名单 LRU Map）两级内核预过滤机制丢弃 94% 事件，再由 Agent 侧规则引擎深度匹配，最终上报量降至 ~100 万事件/分钟。这是目前公开的最具工程深度的 eBPF FIM 生产实践报告。
