# QA 记录：Wazuh FIM whodata eBPF Issue 翻译与分析

> 日期：2026-03-26
> 原文：[FIM whodata eBPF · Issue #27598](https://github.com/wazuh/wazuh/issues/27598)

## 问题

翻译并总结 Wazuh GitHub Issue #27598 关于 FIM whodata eBPF 功能增强的需求描述。

## 回答

已完成翻译与分析，文档保存于 `ebpf/wazuh-fim-whodata-ebpf-issue-翻译与分析-20260326.md`。核心内容：为 Wazuh FIM 模块添加 eBPF 作为 who-data 监控的优先 provider，支持三级优雅降级（eBPF → Audit → inotify），最低内核要求 5.8，使用 C++ 实现，支持 12 个主流 Linux 发行版。Issue 已关闭（Done），功能已实现。
