# QA 记录：eBPF 文件系统监控实战文章翻译与分析

> 日期：2026-03-26

## 用户请求

翻译并总结 Joel Schumacher 的文章 "eBPF File System Monitoring"。

## 输出文件

- `ebpf/ebpf-file-system-monitoring-practical-guide-翻译与分析-20260326.md`

## 关键结论

### 核心价值
这是一篇一线开发者的实战记录，补充了商业方案博客不会暴露的实际痛点。

### 需要追踪的 6 个内核函数
filp_close、vfs_sync_range、vfs_writev、do_splice_from、vfs_truncate、vfs_rename

### 主要挑战
1. vfs_close 被内联无法钩入
2. 路径解析需遍历 dentry 链 + vfsmount，某些函数缺少 vfsmount 信息
3. 验证器不追踪值间关系，需缓冲区加倍 + 位掩码限制
4. 内核 ABI 不稳定 + __randomize_layout 可能阻塞方案

### 作者结论
eBPF FIM 高效、灵活、但脆弱，长期维护负担可能使权衡逐渐不利。
