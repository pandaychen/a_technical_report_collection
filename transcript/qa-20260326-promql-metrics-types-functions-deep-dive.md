# QA 记录：PromQL 核心知识梳理

> 日期：2026-03-26

## 问题

请梳理 PromQL 基本知识要点，围绕 Counter、Gauge、Histogram 三种指标类型，详细解析常用函数、over_time 系列函数以及常用组合搭配，要求使用经典实例（API 计数器、延迟、HTTP 状态码、API 路径等）。

## 回答

已生成详细文档：`promql/promql-metrics-types-functions-deep-dive-20260326.md`

### 文档结构

1. **Prometheus 数据模型基础** — 时间序列结构、四种指标类型概览、即时向量 vs 范围向量
2. **Counter 类型详解** — `rate`/`irate`/`increase`/`resets` 函数、QPS/错误率/流量计算实例
3. **Gauge 类型详解** — `delta`/`deriv`/`predict_linear`/`changes` 函数、内存/CPU/磁盘预测实例
4. **Histogram 类型详解** — `histogram_quantile` 核心函数、Bucket 设计、SLO 监控、RED 方法实例
5. **over_time 系列函数全集** — 11 个 `*_over_time` 函数详解及子查询语法
6. **聚合操作符与分组** — `sum`/`avg`/`topk` 等聚合及 `by`/`without`/向量匹配
7. **实战组合模式** — 四大黄金信号（Latency/Traffic/Errors/Saturation）、USE 方法、多维度分析模板
8. **高级技巧与踩坑指南** — 7 个实用技巧、7 个常见坑、性能优化、Recording Rules 示例

### 核心要点总结

- **Counter** → 必须经过 `rate`/`increase` 转换，绝对值无意义
- **Gauge** → 可直接使用，配合 `*_over_time` 系列做时间窗口聚合
- **Histogram** → `histogram_quantile` + `rate` + `sum by (le)` 是黄金组合
- `rate` 窗口建议 ≥ 4 倍 scrape_interval
- `histogram_quantile` 的 `by` 子句必须包含 `le` 标签
- 不要对 Counter 直接使用 `*_over_time` 系列函数
