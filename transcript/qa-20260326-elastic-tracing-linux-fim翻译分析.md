# QA 记录：Elastic Linux FIM 追踪技术翻译与分析

> 日期：2026-03-26

## 用户请求

翻译并分析 Elastic 博客文章 "Tracing Linux: A file integrity monitoring use case"。

## 输出文件

- `ebpf/elastic-tracing-linux-fim-use-case-翻译与分析-20260326.md`

## 关键结论

### Elastic 的核心创新：tk-btf
- 将 BTF 可移植性方法从 eBPF 扩展到 KProbes
- 使老旧内核（低至 3.3）也能获得带用户/进程信息的 FIM
- BTF 文件极致压缩：54GB → 24KB

### Auditbeat 8.14 三套 FIM 方案
- inotify（GA，默认，无用户信息）
- eBPF（Beta，现代内核，含用户信息）
- KProbes + tk-btf（Beta，老旧内核，含用户信息）

### 与 Tetragon/Sysdig FIM 的定位差异
- Tetragon：最强安全能力（内联执行、Inode-based）
- Sysdig：易用性和集成性
- Elastic：最大兼容性（老旧内核支持）
