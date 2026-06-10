# QA 记录：Pixie Labs eBPF 调试系列三篇连载翻译与分析

> 日期：2026-03-26
> 原文：
> - [Part 1: Tracing Go function arguments in prod](https://blog.px.dev/ebpf-function-tracing/)
> - [Part 2: Tracing full body HTTP request/responses](https://blog.px.dev/ebpf-http-tracing/)
> - [Part 3: Tracing SSL/TLS connections](https://blog.px.dev/ebpf-openssl-tracing/)

## 问题

翻译并总结 Pixie Labs 关于使用 eBPF 调试应用的三篇连载文章。

## 回答

已完成翻译与深度分析，文档保存于 `ebpf/pixie-debugging-with-ebpf-series-翻译与分析-20260326.md`。核心内容：
- Part 1：使用 Uprobe + int3 软中断在 Go 二进制函数入口捕获参数
- Part 2：Kprobe（syscall 层）vs Uprobe（net/http 库）两种 HTTP 追踪方案对比，性能测试显示 >1ms 延迟时开销可忽略
- Part 3：在 OpenSSL 共享库的 SSL_write/SSL_read 上挂 Uprobe，在加密前捕获明文，通过 Entry/Return 配对 + BPF_HASH 暂存 buf 指针实现跨探针数据传递
- 贯穿全系列的核心模式：Entry/Return 探针配对、PID 过滤、per-CPU 临时缓冲区、Perf Buffer 异步传输
