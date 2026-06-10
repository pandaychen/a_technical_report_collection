# QA 记录：Wazuh FIM 实现方案翻译与分析

> 日期：2026-03-26

## 用户请求

翻译并总结 Medium 文章 "Implementing Robust File Integrity Monitoring (FIM) with Wazuh"。

## 处理过程

1. Medium 被 Cloudflare 保护无法直接抓取，通过 Web 搜索获取文章核心内容
2. 结合 Wazuh 官方文档补充技术细节
3. 与此前分析的 Sysdig/Tetragon/Elastic FIM 方案进行综合对比

## 输出文件

- `ebpf/wazuh-fim-implementation-翻译与分析-20260326.md`

## 关键结论

### Wazuh FIM 核心特点
- 三种检测方法：定时扫描 + 实时监控（inotify）+ Who-data 归因（eBPF/AuditD）
- 文件哈希比对（MD5/SHA-1/SHA-256）+ 内容 Diff 报告
- 跨平台：Windows（含注册表）、Linux、macOS
- 三层降级：eBPF → AuditD → inotify

### 综合选型建议
- 合规审计：Wazuh FIM（哈希 + Diff + 合规报告）
- 云原生安全：Tetragon（内联执行 + 防绕过）
- 老旧内核：Elastic tk-btf（低至 3.3）
- 混合环境：Wazuh（主机层）+ Tetragon（容器层）
