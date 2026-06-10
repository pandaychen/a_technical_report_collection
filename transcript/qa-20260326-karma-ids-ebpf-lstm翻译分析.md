# QA 记录：Karma IDS eBPF + LSTM 入侵检测系统翻译与分析

> 日期：2026-03-26
> 原文：[Karma IDS: An Intrusion Detection System using eBPF and LSTM](https://dev.to/pree2111/karma-ids-497p)

## 问题

翻译并总结关于 Karma IDS——基于 eBPF 和 LSTM 的入侵检测系统的文章。

## 回答

已完成翻译与分析，文档保存于 `ebpf/karma-ids-ebpf-lstm-intrusion-detection-翻译与分析-20260326.md`。核心内容：黑客马拉松项目，使用 eBPF（BCC 框架）在内核层捕获网络数据包特征，经预处理后输入预训练的 LSTM 模型进行威胁分类。使用 UNSW-NB15 数据集训练，通过 Focal Loss 解决类别不平衡问题。项目展示了 eBPF + AI 在安全检测中的结合可能性，但作为 PoC 距离生产级系统有距离。
