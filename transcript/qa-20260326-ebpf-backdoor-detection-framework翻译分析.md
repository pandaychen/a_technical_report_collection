# QA 记录：eBPF 后门检测框架与最新方法论翻译与分析

> 日期：2026-03-26
> 原文：[Detection Frameworks and Latest Methodologies for eBPF-Based Backdoors](https://windshock.github.io/en/post/2025-04-29-ebpf-backdoor-detection-framework/)

## 问题

翻译并总结关于 eBPF 后门检测框架与最新方法论的综合性安全文章。

## 回答

已完成翻译与深度分析，文档保存于 `ebpf/ebpf-backdoor-detection-framework-翻译与分析-20260326.md`。核心内容：eBPF 的双刃剑本质——既是最强安全工具也是最隐蔽攻击武器；传统杀毒无法检测 eBPF 后门；Tracee（事件记录）+ LKRG（完整性保护）互补；四大检测方法论（实时加载监控、内核完整性检查、Hypervisor 审计、事后取证）；BPFDoor 和 Pamspy 实战案例；以及对 FIM 系统的安全启示——需确保检测系统本身未被篡改。
