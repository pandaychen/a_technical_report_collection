# QA 记录：基于 eBPF 的 Linux 文件系统系统调用运行时监控翻译与分析

> 日期：2026-03-26
> 原文：[eBPF-Based Linux Filesystem Syscall Runtime Monitoring](https://medium.com/@psy_maestro/ebpf-based-linux-filesystem-syscall-runtime-monitoring-8e5a49ff82d9)

## 问题

翻译与总结 psy_maestro 关于使用 eBPF USDT + Tracepoint 双探针联动实现 PHP 文件系统 syscall 运行时监控的技术文章。

## 回答

已完成翻译与深度分析，文档保存于 `ebpf/ebpf-linux-filesystem-syscall-runtime-monitoring-翻译与分析-20260326.md`。核心内容：USDT 探针追踪 PHP 函数调用栈 + Tracepoint 捕获文件系统 syscall，通过共享 eBPF Map 以 PID 为 key 关联，实现源码行级别的文件操作追踪。使用 Ring Buffer 传输到 Rust 用户空间程序。这是本系列唯一实现了用户空间（应用层）与内核空间事件关联的方案。
