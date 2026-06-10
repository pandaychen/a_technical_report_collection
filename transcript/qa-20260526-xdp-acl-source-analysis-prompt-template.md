# QA 记录：为 hi-glenn/xdp_acl 项目生成 Cursor 源码深度分析提示词

> 时间：2026-05-26
> 项目：<https://github.com/hi-glenn/xdp_acl>
> 产出文档：[xdp-acl-source-analysis-prompt-template-20260526.md](../ebpf/xdp-acl-source-analysis-prompt-template-20260526.md)
> 风格参考：[kubearmor-source-analysis-prompt-template-20260525.md](../ebpf/kubearmor-source-analysis-prompt-template-20260525.md)

---

## 一、用户请求

> <https://github.com/hi-glenn/xdp_acl>
> 我现在需要使用 cursor 详细吃透这个项目，请为我生成一段专业的提示词

---

## 二、分析过程

### 2.1 项目情报收集

通过抓取 GitHub 仓库 README 与关键源文件（`xdp_acl.c`、`main.go`、`acl.json`、`rules_original.go`、`rules_immediate.go`），梳理出该项目的核心架构：

| 维度 | 关键信息 |
|------|---------|
| 项目定位 | 高性能 XDP-based ACL（高性能五元组防火墙） |
| 语言占比 | C 86.4% / Go 12.9% |
| 内核要求 | Linux v4.15 + |
| License | GPL-2.0 |
| 关键依赖 | `cilium/ebpf`、`golang.org/x/sys/unix`、`go.uber.org/zap`、Gin（推测） |
| 启发来源 | 论文「A Fast and Flexible Bitmap-based ACL ...」（具体未明确） |

### 2.2 核心架构判定

**算法核心**：基于多字段 bitmap 的并行匹配 + ffs 取最高优先级规则。

**BPF Map 全景**（6 个）：

| Map | 类型 | Key | Value | 用途 |
|-----|------|-----|-------|------|
| `src_v4` | `LPM_TRIE` | `lpm_key_ipv4` | `__u64[160]` | 源 IP/CIDR → 位图 |
| `dst_v4` | `LPM_TRIE` | `lpm_key_ipv4` | `__u64[160]` | 目的 IP/CIDR → 位图 |
| `sport_v4` | `HASH` | `__u16` (net order) | `__u64[160]` | 源端口 → 位图 |
| `dport_v4` | `HASH` | `__u16` (net order) | `__u64[160]` | 目的端口 → 位图 |
| `proto_v4` | `HASH` | `__u32` | `__u64[160]` | 协议号 → 位图 |
| `rule_action_v4` | `PERCPU_HASH` | `{idx, ffs}` | `{action, count}` | 规则编号 → 动作 |

**核心常量**：

- `BITMAP_ARRAY_SIZE = 160` → 最多 `64 × 160 = 10240` 条规则
- `PORT_MAX_ENTRIES_V4 = 65536`
- `PROTO_MAX_ENTRIES_V4 = 4`

**匹配流程**：

```
报文进入 → parse eth/ip/tcp(udp) → 5 次 Map lookup → 收集 5 个 __u64* 到栈
        → 外层 unroll (160/8) × 内层手动展开 8 次的 AND 归并
        → 第一个非零 hit_rules → ffs(hit & -hit) → rule_action_v4.lookup
        → 返回 XDP_PASS / XDP_DROP
```

**用户态架构**：

- 启动期：`loadOriginalRules` 用 6 个 goroutine 并发填充 6 个 Map
- 运行期：`loadImmediateRules` 用 channel fan-out 模式分发到 5 个字段 worker
- Web 控制台：Gin（推测）暴露 `0.0.0.0:9090` RESTful API
- 持久化：`saveFile` goroutine 写回 `acl.json`

### 2.3 性能优化点（代码可证）

| 优化 | 代码证据 |
|------|---------|
| `__always_inline` | 所有 parse/lookup helper |
| `likely`/`unlikely` | `unlikely(3 != *rule_array_len_ptr && 5 != ...)` |
| `____cacheline_aligned` | `rule_array_index`、`hit_rules` 栈变量 |
| `#pragma unroll` | `get_rule_action_v4` 外层循环 |
| 手动展开 8 次 | `get_hit_rules_optimize` 函数体 |
| `BPF_MAP_TYPE_PERCPU_HASH` | `rule_action_v4` 定义 |
| 端口网络序作 Map Key | 省一次 `bpf_ntohs` |
| `BPF_F_NO_PREALLOC` | LPM_TRIE 必备 |

---

## 三、最终交付

依照 `kubearmor-source-analysis-prompt-template-20260525.md` 的「十六进制章节 + 强制源码引用 + Mermaid + draw.io」专业版式，定制了 `xdp_acl` 专属的提示词模板：

### 3.1 模板七大组成部分

1. **使用说明**：clone 命令、参考论文检索建议、交叉验证命令
2. **主提示词**：可直接复制到 Cursor 的完整 prompt（角色定位 / 分析范围 / 写作版式 / 引用规则 / 7 个强制章节）
3. **可选附加模块 A~G**：BPF 行级 / Go 行级 / Web API / XDP attach / Benchmark / 横向对比 / 内核兼容矩阵
4. **可选参数 4.1~4.5**：篇幅 / 英文摘要 / draw.io 图 / 算法可视化 / 工程改进建议
5. **Mermaid 骨架**：整体架构 / 报文匹配时序 / 规则下发时序
6. **自检清单**：12 项发布前检查
7. **使用技巧 + 可能疑点**：让模型遇到不确定时主动提问的引导

### 3.2 与 KubeArmor 模板的差异点

| 维度 | KubeArmor 模板 | xdp_acl 模板 |
|------|---------------|-------------|
| 核心场景 | 安全/LSM/K8s | 网络/XDP/防火墙 |
| Hook 类型 | BPF-LSM / kprobe / tracepoint | XDP only |
| 富化关键 | cgroup → containerID → Pod | 报文 5-tuple → bitmap → action |
| 算法分析 | 不强调 | **重点**：bitmap 多字段并行 + ffs |
| 部署形态 | DaemonSet + Operator + CRD | 单进程 + Web 控制台 + JSON 文件 |
| 横向对比 | Falco / Tetragon / Tracee | iptables / nftables / Cilium / Katran |
| 性能侧重 | 多 enforcer 降级 + LSM 开销 | XDP PPS + bitmap 算法理论极限 + cacheline |

---

## 四、用户规则遵循自检

| 规则 | 落实情况 |
|------|---------|
| ①每次 plan 单独存储 + 标明时间 + 中文 | 提示词模板含日期与中文，已落盘到 `ebpf/xdp-acl-source-analysis-prompt-template-20260526.md` |
| ②若有设计文档需先看 | 用户未提供本地设计文档，已通过抓取仓库源码代替 |
| ③技术方案选型不准时提问 | 在第八节「可能遇到的疑点」中预置了 6 条建议向用户确认的问题（如启发论文、IPv6 路线图等） |
| ④不知道就说不知道 | 启发论文具体名称未武断认定，仅给候选并要求模型在「0xFF」中说明判定依据 |
| ⑤git 操作按 devops 标准 | 本次无 git 改动 |
| ⑥每次 qa 落盘 | 本文件即为本次落盘 |
| ⑦开源方案推荐 | 提示词附加 F 中预置了与 Cilium / Katran / l4drop / xdp-tutorial 的横向对比 |
| ⑧markdown + mermaid + drawio | 提示词强制 5 张 Mermaid + drawio 节点清单 |
| ⑨QA 保存到 transcript 目录 | 路径：`transcript/qa-20260526-xdp-acl-source-analysis-prompt-template.md` |

---

## 五、下一步建议

1. **本地 clone 仓库**后，把第二节「主提示词」整段贴给 Cursor，让其产出深度分析正文
2. 若希望聚焦算法，把附加模块 A（BPF 行级）追加到主提示词
3. 若希望聚焦工程化改进，把可选参数 4.5（工程改进建议）追加进去
4. 产出文件建议保存为 `ebpf/xdp-acl-深度技术分析-YYYYMMDD.md`
