# QA 记录：Sysdig/eBPF 系列文章翻译与 FIM 深度分析

> 日期：2026-03-26

## 用户请求

翻译并总结 6 篇 Sysdig/Falco/eBPF 相关文章，着重分析 FIM 的实现机制、支持的功能以及是否支持敏感文件抓取。

## 处理的文章

1. [Sysdig and Falco now powered by eBPF](https://www.sysdig.com/blog/sysdig-and-falco-now-powered-by-ebpf)（已在前次对话中完成）
2. [The art of writing eBPF programs: a primer](https://www.sysdig.com/blog/the-art-of-writing-ebpf-programs-a-primer)
3. [Introducing container observability with eBPF + Sysdig](https://www.sysdig.com/blog/introducing-container-observability-with-ebpf-and-sysdig)
4. [Falco vs. AuditD from the HIDS perspective](https://www.sysdig.com/blog/falco-vs-auditd-hids)
5. [FIM Policy 官方文档](https://docs.sysdig.com/en/sysdig-secure/fim-policy/)
6. [Sysdig contributes Falco's kernel module, eBPF probe, and libraries to the CNCF](https://www.sysdig.com/blog/sysdig-contributes-falco-kernel-ebpf-cncf)

## 输出文件

所有文件归类到 `ebpf/` 一级目录：

| 文件名 | 内容 |
|--------|------|
| `sysdig-and-falco-now-powered-by-ebpf-翻译与总结-20260326.md` | 第 1 篇翻译（前次完成） |
| `the-art-of-writing-ebpf-programs-a-primer-翻译与总结-20260326.md` | 第 2 篇翻译 |
| `introducing-container-observability-with-ebpf-and-sysdig-翻译与总结-20260326.md` | 第 3 篇翻译 |
| `falco-vs-auditd-hids-翻译与总结-20260326.md` | 第 4 篇翻译 |
| `sysdig-contributes-falco-kernel-ebpf-cncf-翻译与总结-20260326.md` | 第 6 篇翻译 |
| `sysdig-fim-policy-深度分析-20260326.md` | FIM 深度分析（含第 5 篇翻译） |

## 关键结论

### FIM 实现机制
- 基于 Universal eBPF 探针的系统调用追踪
- 通过 libscap + libsinsp 实现事件捕获和丰富化
- 用户态进行路径匹配和策略评估

### FIM 支持的功能
- 文件修改检测和文件删除检测
- 目录级监控和排除
- 正则表达式路径匹配（RE2）
- 主机/容器/自定义作用域
- 告警通知集成

### 敏感文件抓取
- FIM 本身不支持文件内容抓取
- Falco 规则可检测敏感文件被读取（但不抓取内容）
- Sysdig Captures 可录制系统调用数据流（含读写缓冲区内容），用于取证
