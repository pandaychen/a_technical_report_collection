# QA 记录：Cursor 深度分析 eBPF 项目通用提示词模版

> 日期：2026-03-26

## 问题

作为 HIDS/eBPF 内核专家，需要一个通用提示词模版，用于在 Cursor 中系统性拆解任意开源 eBPF 项目的架构、Hook 点、功能实现和技术手法。

## 回答

已创建八阶段递进式分析模版，保存于 `ebpf/cursor-ebpf-project-analysis-prompt-template.md`。涵盖：全局架构、Hook 全景、Maps 与数据流、用户空间逻辑、核心功能深度分析、安全对抗分析、性能与工程质量、综合报告。另附四类项目（HIDS、网络安全、FIM、Rootkit 检测）的补充提示词。
