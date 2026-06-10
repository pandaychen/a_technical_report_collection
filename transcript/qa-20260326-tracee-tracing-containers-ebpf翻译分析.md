# QA 记录：Tracee 使用 eBPF 追踪容器事件翻译与分析

> 日期：2026-03-26
> 原文：[Tracee: Tracing Containers with eBPF](https://www.aquasec.com/blog/ebpf-tracing-containers/)

## 问题

翻译并总结 Aqua Security 发布的 Tracee 开源项目首发博文。

## 回答

已完成翻译与分析，文档保存于 `ebpf/tracee-tracing-containers-with-ebpf-翻译与分析-20260326.md`。核心内容：Tracee 通过 PID 命名空间检测（检查进程在其命名空间中的 PID 是否为 1）来零依赖地识别容器启动，只追踪容器内事件而过滤宿主机噪声。这是最轻量的容器感知方案——完全在内核中通过 eBPF 访问 task_struct 实现，无需容器运行时 API。
