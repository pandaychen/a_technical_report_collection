# QA 记录：三个典型 eBPF HIDS 项目深度对比分析

> 日期：2026-03-26
> 分析项目：eHIDS-agent、tested、Wazuh

## 问题

使用之前创建的 Cursor eBPF 项目分析提示词模版，对比分析 eHIDS-agent、tested、Wazuh 三个典型项目。

## 回答

已完成全面对比分析，文档保存于 `ebpf/ebpf-hids-projects-comparative-analysis-20260326.md`。涵盖：架构对比、Hook 全景（eHIDS 5 个 / tested 21 个 / Wazuh FIM 专用）、Hook 间关系分析（进程执行链、无文件攻击检测链、Rootkit 检测矩阵、文件操作审计链）、ATT&CK 覆盖映射、工程质量评估、使用 Cursor 深入分析的建议路径。
