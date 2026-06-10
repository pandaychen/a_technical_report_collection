# QA 记录：构建文件系统监视器 eBPF 实践翻译与分析

> 日期：2026-03-26
> 原文：[The Rabbit Hole of Building a Filesystem Watcher](https://amandeepsp.github.io/blog/fs-watcher/)

## 问题

翻译与总结 Amandeep Singh 关于使用 eBPF 构建文件系统监视器的技术博文。

## 回答

已完成翻译与深度分析，文档保存于 `ebpf/building-filesystem-watcher-ebpf-翻译与分析-20260326.md`。核心内容包括：从 fanotify 到 eBPF VFS kprobe 再到 LSM 钩子的方案演进、dentry 树遍历的实现细节（inode 号比较 + RCU 锁 + 有界循环）、以及与本系列其他 FIM 文章的关联分析。
