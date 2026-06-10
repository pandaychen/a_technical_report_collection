# eBPF + Kubernetes 安全与可观测项目推荐 技术对话记录

> 日期：2026-04-09
> 会话主题：eBPF + Kubernetes 安全/可观测主流开源项目推荐与架构分析
> 参与方：用户 + Cursor AI

---

## 会话概要

用户作为 eBPF/Kubernetes/可观测领域专家，希望获得一份系统性的主流 eBPF + K8s 安全与可观测开源项目推荐清单。本次会话覆盖了 8 个具有代表性的项目（Falco、Tetragon、Tracee、KubeArmor、Cilium/Hubble、Pixie、Parca/Pyroscope、Inspektor Gadget），从核心理念、应用场景、核心原理到架构图均有详细说明。所有内容基于已知知识，无编造。

## 使用的 Skills

- `save-qa-record`：保存本次对话记录

---

## 详细对话记录

### Q1：推荐易读、广泛好评、有使用基数的 eBPF + K8s 安全/可观测项目

**用户提问：**
> 你是一名 ebpf/kubernetes/可观测专家，请为我推荐一些易读、广泛好评、有一定使用基数的 ebpf && kubernetes 的安全、可观测项目，并注明项目的核心理念，应用场景，核心原理以及架构。如果有疑问，先向我提问，不要编造回答。

**分析过程：**
- 基于已知的 CNCF 生态、Aqua Security、Isovalent 等主流厂商的开源项目进行筛选
- 筛选标准：GitHub Stars > 2k、生产级可用、有明确 K8s 集成、基于 eBPF 驱动
- 无不确定项，直接输出结论

**结论/输出：**

---

## 一、安全类项目

### 1. Falco（CNCF 毕业项目）

| 项目信息 | 详情 |
|----------|------|
| GitHub | [falcosecurity/falco](https://github.com/falcosecurity/falco) |
| Stars | ~7.5k |
| 维护方 | CNCF + Sysdig |

**核心理念：** 基于规则引擎的运行时异常检测，将内核事件语义化为"安全规则"，强调 **可解释性** 而非黑盒检测。

**应用场景：**
- 容器/Pod 内异常进程执行（如 shell 在 nginx 容器内执行）
- 敏感文件访问（如 `/etc/shadow`、`/proc/sysrq-trigger`）
- 网络异常连接、权限提升检测
- K8s Audit Log 安全分析

**核心原理：**
- 早期依赖内核模块，现代版本以 eBPF 为主驱动（`falco-libs` 中的 `libs/driver/bpf`）
- 挂载 `sys_enter_*` / `sys_exit_*` 系列 tracepoint，捕获所有 syscall 事件
- 事件流经 `libscap`（采集层）→ `libsinsp`（语义富化，附加进程树、容器元数据）→ 规则引擎（YAML 规则）
- 规则使用类 SQL 的 Falco Rule 语言，支持宏/列表复用

**架构（mermaid）：**

```mermaid
graph TD
    A[eBPF Driver / Kernel Module] -->|原始 syscall 事件| B[libscap 采集层]
    B --> C[libsinsp 语义富化]
    C -->|进程树/容器元数据| D[规则引擎 Falco Engine]
    D -->|告警| E[输出插件: stdout/gRPC/K8s Audit/SIEM]
    F[K8s Audit Webhook] --> D
```

---

### 2. Tetragon（Cilium 生态）

| 项目信息 | 详情 |
|----------|------|
| GitHub | [cilium/tetragon](https://github.com/cilium/tetragon) |
| Stars | ~4k |
| 维护方 | Isovalent/Cilium |

**核心理念：** **安全可观测性 + 实时执行策略（In-kernel Enforcement）**，不仅观测还能在内核层直接阻断，通过 `TracingPolicy` CRD 声明式配置 eBPF 程序行为。

**应用场景：**
- 进程执行链跟踪（完整 ancestry，防 PPID 欺骗）
- 文件完整性监控（FIM）
- 网络连接四元组跟踪 + 策略执行
- 权限提升/capability 变更检测
- K8s workload 感知的安全事件关联

**核心原理：**
- 使用 `kprobe` / `tracepoint` / `LSM hook` 三类挂载点
- 独创 **`TracingPolicy` CRD** —— 用 YAML 描述"挂哪个内核函数、读哪些参数、触发什么动作（观测/覆盖返回值/SIGKILL）"
- 内核侧通过 eBPF map 维护进程树，确保容器内 exec 链路可追溯
- 事件通过 perf ring buffer 上报，Go 侧 daemon 负责富化 K8s metadata 并导出 gRPC/JSON

**架构（mermaid）：**

```mermaid
graph TD
    A[TracingPolicy CRD] -->|声明式加载| B[Tetragon Daemon]
    B -->|动态加载 eBPF 程序| C[Kernel: kprobe/LSM/tracepoint]
    C -->|ring buffer 事件| B
    B -->|富化 K8s metadata| D[gRPC Server]
    D --> E[CLI tetra]
    D --> F[SIEM / Prometheus / Hubble UI]
```

---

### 3. Tracee（Aqua Security）

| 项目信息 | 详情 |
|----------|------|
| GitHub | [aquasecurity/tracee](https://github.com/aquasecurity/tracee) |
| Stars | ~4k |
| 维护方 | Aqua Security |

**核心理念：** **取证导向的运行时安全**，提供丰富的内置检测签名（Go 编写），同时开放事件流供自定义分析，强调 **低侵入、易扩展**。

**应用场景：**
- 容器逃逸检测（`runc` 漏洞利用路径）
- 内核漏洞利用行为特征检测
- 供应链安全（镜像运行时行为基线）
- 实时事件流接入 Kafka/其他 SIEM

**核心原理：**
- 基于 CO-RE（Compile Once - Run Everywhere），使用 `vmlinux.h` 跨内核兼容
- 挂载 `raw_syscalls:sys_enter/exit` + 部分 kprobe 覆盖网络、文件、进程事件
- 事件流经 Go 侧 pipeline，内置 Rego（OPA）或 Go 编写的"签名（Signature）"进行检测
- 支持 `tracee-rules` 独立运行检测引擎，也支持直接订阅原始事件流

**架构（mermaid）：**

```mermaid
graph TD
    A[eBPF 程序 CO-RE] -->|perf buffer| B[Tracee-eBPF 进程]
    B -->|结构化事件流| C[Tracee-Rules 检测引擎]
    C -->|Go Signatures / Rego| D[告警输出 JSON/gRPC]
    B -->|原始事件| E[外部消费: Kafka/Falco/SIEM]
```

---

### 4. KubeArmor

| 项目信息 | 详情 |
|----------|------|
| GitHub | [kubearmor/KubeArmor](https://github.com/kubearmor/KubeArmor) |
| Stars | ~2k |
| 维护方 | AccuKnox (CNCF Sandbox) |

**核心理念：** **以 K8s 原生方式声明运行时安全策略**，通过 `KubeArmorPolicy` CRD 限制 Pod 内进程/文件/网络行为，支持 LSM（AppArmor/SELinux）和 eBPF 双后端。

**应用场景：**
- 零信任 Pod 内进程白名单
- 禁止容器内 `curl`/`wget`/`bash` 等危险操作
- 文件写保护（只读路径声明）
- 替代复杂的 AppArmor Profile 手写

---

## 二、可观测类项目

### 5. Cilium + Hubble

| 项目信息 | 详情 |
|----------|------|
| GitHub | [cilium/cilium](https://github.com/cilium/cilium) |
| Stars | ~21k |
| 维护方 | CNCF 毕业项目 |

**核心理念：** **用 eBPF 重写 K8s 网络层**，kube-proxy 替代 + 网络策略执行 + 全链路 L3-L7 可观测性，Hubble 是其可观测性子系统。

**核心原理（可观测部分 Hubble）：**
- eBPF 程序挂载 TC（Traffic Control）hook，监控所有 Pod 出入流量
- 流量元数据写入 perf ring buffer，Hubble Observer 消费并富化为 `Flow` 对象
- Hubble Relay 聚合多节点数据，提供集群级别的 gRPC API

**架构（mermaid）：**

```mermaid
graph TD
    A[Pod 网络包] -->|TC hook eBPF| B[cilium-agent per node]
    B -->|Flow 事件| C[Hubble Observer]
    C --> D[Hubble Relay 聚合]
    D --> E[Hubble UI 拓扑图]
    D --> F[Prometheus metrics]
    D --> G[CLI hubble observe]
```

---

### 6. Pixie（New Relic 捐赠 CNCF）

| 项目信息 | 详情 |
|----------|------|
| GitHub | [pixie-io/pixie](https://github.com/pixie-io/pixie) |
| Stars | ~5.5k |
| 维护方 | CNCF Sandbox |

**核心理念：** **无侵入式（Zero-instrumentation）K8s 应用可观测**，无需修改应用代码或注入 sidecar，通过 eBPF uprobes 自动解析 HTTP/gRPC/MySQL/Redis 等协议。

**应用场景：**
- 自动生成服务调用 flamegraph（无需 APM SDK）
- HTTP/gRPC 请求体内容自动解析（L7 可见性）
- CPU profile（eBPF sampling profiler）
- 集群资源水位分析

**核心原理：**
- 使用 `uprobe` 挂载 Go/Python/Node 运行时的 TLS/协议函数，绕过加密获取明文
- 用 `kprobe` 捕获 syscall 级别的网络 I/O
- 内置 PxL（Pixie Language）查询引擎，数据留在节点本地（in-node analytics）

---

### 7. Parca / Pyroscope（持续剖析）

| 项目信息 | 详情 |
|----------|------|
| Parca GitHub | [parca-dev/parca-agent](https://github.com/parca-dev/parca-agent) |
| Pyroscope GitHub | [grafana/pyroscope](https://github.com/grafana/pyroscope) |

**核心理念：** **Always-on CPU/Memory profiling**，基于 eBPF sampling profiler，~1% CPU 开销采集全集群 flamegraph。

**核心原理：**
- 使用 `perf_event_open` + eBPF 程序在固定频率（99Hz）对所有进程做 CPU 采样
- 通过 DWARF/frame pointer 展开调用栈
- 支持混合语言 flamegraph（Go + C + Kernel 混合栈）

---

### 8. Inspektor Gadget

| 项目信息 | 详情 |
|----------|------|
| GitHub | [inspektor-gadget/inspektor-gadget](https://github.com/inspektor-gadget/inspektor-gadget) |
| Stars | ~3k |
| 维护方 | Microsoft / CNCF Sandbox |

**核心理念：** **K8s-aware 的 eBPF 工具箱**，将 bcc/bpftrace 工具容器化并赋予 K8s 语义，通过 `kubectl gadget` 直接对 Pod/Node 执行诊断。

**应用场景：**
- `kubectl gadget top file --namespace=prod` 看文件 I/O top
- `kubectl gadget trace dns` 抓 Pod DNS 请求
- `kubectl gadget trace tcp` 看 TCP 连接建立

---

### Q2：补充 Alaz（getanteon/alaz）项目介绍

**用户提问：**
> 补充一下 https://github.com/getanteon/alaz 这个项目

**分析过程：**
- 读取用户上传的 GitHub 页面文档（alaz-0.md）
- 抓取官方 ARCHITECTURE.md 获取技术细节
- 重点分析 eBPF 程序设计、TLS 解密方案、三层数据来源架构

**结论/输出：**

---

## 补充：9. Alaz（Anteon eBPF Agent）

| 项目信息 | 详情 |
|----------|------|
| GitHub | [getanteon/alaz](https://github.com/getanteon/alaz) |
| Stars | ~718 |
| 维护方 | Anteon（前身为 Ddosify） |
| License | AGPLv3 |
| 语言构成 | C 58.3% + Go 41.1% |

**核心理念：** **面向 K8s 服务拓扑的七层流量可观测**，无需代码埋点、无需 sidecar，通过 eBPF 自动捕获并解析服务间的 L7 协议，生成实时 Service Map，识别服务间高延迟、5xx 错误、Zombie 服务等黄金信号。

**应用场景：**
- K8s 服务依赖 Service Map 自动生成（无需 Jaeger/Zipkin 埋点）
- HTTP/gRPC 高延迟链路定位
- 慢 SQL 检测（MySQL/Postgres）
- 检测 Idle/Zombie 服务（节省资源）
- 性能压测与可观测联动（Anteon 压测 + Alaz 同步监控）
- Prometheus 节点指标采集（CPU/Memory/Disk/Network）

**核心原理：**

Alaz 数据来源分三层：

**第一层：K8s Client 事件监听**
- 通过 `client-go` 监听 Pod/Service/Deployment 的 ADD/UPDATE/DELETE 事件，维护集群拓扑元数据，为网络流量提供 K8s 语义映射

**第二层：Container Runtime 信息采集**
- 通过连接 `containerd` socket，获取容器 PID、cgroup、sandbox 信息，将网络流量与容器身份精确关联

**第三层：eBPF 程序（核心）**

使用 `cilium/ebpf` + `bpf2go` 工具链，内核侧 C 程序编译后通过 `//go:embed` 嵌入 Go 二进制，运行时加载。

| 程序 | 职责 | 挂载点 |
|------|------|--------|
| `tcp_state` | 跟踪 TCP 连接建立/关闭/监听，维护 fd→socket 映射 | `tracepoint/sock/inet_sock_set_state`、`sys_enter/exit_connect` |
| `l7_req` | 捕获 write/read/sendto/recvfrom payload，解析 L7 协议 | `sys_enter/exit_write/read/sendto/recvfrom` 共 8 个 tracepoint |

**TLS 解密（uprobe 方案）：**
- OpenSSL：挂 `SSL_write` / `SSL_read` uprobe，支持 1.0.2 / 1.1.1 / 3.x
- Go TLS：挂 `crypto/tls.(*Conn).Write` / `(*Conn).Read`
- ⚠️ **工程重点**：uretprobe 会导致 Go 程序崩溃，Alaz 通过反汇编可执行文件找到所有 `RET` 指令地址，在其上挂普通 uprobe 替代 uretprobe

**架构（mermaid）：**

```mermaid
graph TD
    subgraph K8s Node
        A1[K8s API Server] -->|client-go watch| B[Alaz DaemonSet Pod]
        A2[containerd socket] -->|CRI 元数据| B

        subgraph eBPF Layer
            C1[tcp_state\ntracepoint: sock/inet_sock_set_state\nsys_enter/exit_connect]
            C2[l7_req\ntracepoint: sys_enter/exit_write/read\nsendto/recvfrom]
            C3[uprobe: SSL_write/SSL_read\ncrypto/tls Write/Read]
        end

        C1 -->|TCP 连接映射| D[perf ring buffer]
        C2 -->|L7 payload| D
        C3 -->|TLS 明文| D
        D -->|Go userspace 消费| B
    end

    B -->|Service Map + 黄金信号| E[Anteon Cloud / Self-Hosted]
    B -->|Node 指标| F[Prometheus Node Exporter]
    E --> G[Service Map 可视化 UI]
    E --> H[告警: Slack / 异常检测]
```

**支持协议：** HTTP 1.x、HTTPS（OpenSSL/Go TLS）、HTTP/2、gRPC、PostgreSQL、MySQL、MongoDB、Redis（RESP）、Kafka、RabbitMQ

**内核要求：** CO-RE + BTF，主流发行版（Ubuntu 20.04+/CentOS 8+）均已支持

---

## 三、综合对比表（更新）

| 项目 | 类型 | K8s 原生 | 执行策略 | 侵入性 | 适合场景 |
|------|------|----------|----------|--------|----------|
| Falco | 安全检测 | ✅ | ❌（告警为主） | 无 | SOC 告警、合规 |
| Tetragon | 安全+执行 | ✅ | ✅（内核级阻断） | 无 | 零信任、FIM |
| Tracee | 安全取证 | ✅ | ❌ | 无 | 漏洞检测、供应链 |
| KubeArmor | 策略执行 | ✅ | ✅ | 无 | 白名单管控 |
| Cilium/Hubble | 网络可观测 | ✅ | ✅（网络策略） | 替换 kube-proxy | 网络 L7 可见性 |
| Pixie | APM 可观测 | ✅ | ❌ | 无 | 无埋点 APM + CPU profiling |
| **Alaz** | **服务拓扑可观测** | ✅ | ❌ | 无 | **Service Map + 压测联动** |
| Parca/Pyroscope | 持续剖析 | ✅ | ❌ | 无 | 性能优化 |
| Inspektor Gadget | 调试工具箱 | ✅ | ❌ | 无 | 运维诊断 |

---

## 生成的产物清单

| # | 文件名 | 类型 | 说明 |
|---|--------|------|------|
| 1 | `transcript/qa-20260409-ebpf-kubernetes-security-observability-projects.md` | 文档 | 本次对话记录 |

## 后续待办

- [ ] 选择 1-2 个项目进行源码级深度分析（如 Tetragon TracingPolicy 加载机制）
- [ ] 设计 Cilium + Tetragon + Falco 分层安全架构方案
- [ ] 针对具体场景（FIM/容器逃逸/网络审计）做选型对比报告
