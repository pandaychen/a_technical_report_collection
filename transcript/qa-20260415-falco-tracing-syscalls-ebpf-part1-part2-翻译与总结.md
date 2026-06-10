# QA 记录：Falco 博客《用 eBPF 追踪系统调用》两篇翻译与总结

> 日期：2026-04-15  
> 原文：  
> - [Tracing System Calls Using eBPF - Part 1](https://falco.org/blog/tracing-syscalls-using-ebpf-part-1/)（2023-09-11）  
> - [Tracing System Calls Using eBPF - Part 2](https://falco.org/blog/tracing-system-calls-using-ebpf-part-2/)（2023-10-06）  
> 作者：Anshu Bansal, Rakshit Awasthi, Ashutosh Venkatrao More  

## 问题

翻译并总结上述两篇 Falco 官方博客文章。

## 回答（翻译要点与总结）

### 第一篇：基础概念、为何 Falco 用 eBPF、tracepoint 示例与 ring buffer

**1. BPF 与 eBPF**

- **BPF（Berkeley Packet Filter）**：最初用于网络包过滤与分析，可用于防火墙、IDS、实时流量检测等。
- **eBPF（Extended BPF）**：在 BPF 之上演进，可在内核中加载程序并挂接到多种钩子与事件，用于动态追踪、网络分析、性能监控，向用户空间提供实时洞察与控制。

**2. eBPF 程序从编写到运行的典型步骤**

1. 编译器将 eBPF 程序编译为字节码，供加载器加载。  
2. **验证器（verifier）**：对所有执行路径做深度优先搜索，保证程序能终止；再做静态分析，检查内存访问与安全约束。  
3. 验证通过后由加载器加载进内核并挂到目标钩子。  
4. 运行时经 **JIT** 将字节码编译为机器码执行。

**3. 内核模块 vs eBPF（文中对比）**

| 维度 | eBPF | 内核模块 |
|------|------|----------|
| 安全与隔离 | 加载前严格验证 | 直接访问内核，实现不当风险大 |
| 性能 | JIT 后执行效率高；但相较「纯内核模块插桩」，经 BPF 子系统会有额外开销 | 不经 BPF 子系统，同等工作量下开销可能更低 |
| 可观测与调试 | 易挂接多种事件，便于调试与监控 | 往往需要更侵入、更复杂的手段 |

**4. Falco 为何需要 eBPF**

- Falco 已有基于 **kprobe** 的实时检测能力。  
- 引入 eBPF 的重要动机是：在**现代云原生环境**中，传统内核 probe 可能在控制面节点上受限；eBPF 路径有助于在更多环境下**持续、安全地**保持实时检测能力。

**5. 挂接与示例：`execve` tracepoint**

- 内核中存在多种**插桩点**：kprobe、tracepoint、uprobe、kretprobe 等。  
- 使用 `bpf/bpf_helper.h` 中的 **`SEC()`** 宏，把函数放到 eBPF 对象文件的指定段，便于加载器定位。  
- tracepoint 的段名形如：`SEC("tp/<category>/<name>")`。  
- 示例：`tp/syscalls/sys_enter_execve` 表示进程发起 `execve` 系统调用时触发。  
- 可用 tracepoint 列表可参考：`/sys/kernel/debug/tracing/available_events`，格式为 `<category>:<name>`（如 `syscalls:sys_enter_execve`）。  
- 简单场景下可用 **`bpf_printk`** 输出，通过读取 `/sys/kernel/tracing/trace_pipe` 查看。

**6. Ring buffer（`bpf_ringbuf`）与用户态通信**

- **bpf_ringbuf** 是内核提供的 eBPF 与用户空间高效通信机制；**MPSC（多生产者单消费者）**，可跨 CPU 安全共享。  
- 相较 per-CPU 的 perf buffer，ring buffer 统一管理内存，减轻分配不均问题。  
- 文中涉及的关键 API 概念：  
  - `bpf_ringbuf_reserve` / `bpf_ringbuf_submit`：预留与提交数据；  
  - `bpf_probe_read_user_str`：从用户空间读以 null 结尾的字符串；  
  - libbpf 侧如 `bpf_object__find_map_fd_by_name`、`bpf_program__attach_tracepoint`、`ring_buffer__new`、`ring_buffer__consume` 等。  
- 用户态 loader 中通过循环调用 `ring_buffer__consume()` 持续拉取事件；文中示例在循环中加 `sleep(1)` 以降低 CPU 占用。

**7. BTF（BPF Type Format）**

- 用于描述 eBPF 程序使用的数据结构类型，增强类型安全、调试与 introspection。

---

### 第二篇：Uprobe/Uretprobe 与 Kprobe/Kretprobe

**1. Uprobe / Uretprobe**

- **Uprobe**：在用户态程序**不修改源码**的情况下，在指定地址/函数入口插桩，用于采集数据、追踪调用、调试与性能分析。  
- **Uretprobe**：针对**函数返回路径**，在从被测函数返回时触发，与 uprobe（入口）互补。

文中示例：对 **glibc 的 `printf`** 使用 uprobes 追踪；loader 与 Part 1 类似，也可从 `/sys/kernel/tracing/trace_pipe` 读日志。

**2. Kprobe / Kretprobe**

- **Kprobe**：动态在**内核函数入口**插桩，用于性能分析、排错、监控；可观察参数、返回值（配合 kretprobe）、统计等。  
- **Kretprobe**：在**内核函数返回点**插桩，可收集返回时上下文、在合规场景下分析返回值等。

文中示例：对内核函数 **`prepare_kernel_cred`** 使用 kprobe。该函数用于创建新的 `struct cred`（任务凭据），在**权限提升类漏洞利用**中常被滥用；追踪其调用有助于发现可疑活动。

- 段名示例：`SEC("kprobe/prepare_kernel_cred")`。  
- **`struct pt_regs`**：在 eBPF 触发时反映 CPU 寄存器状态，便于解析参数与上下文。  
- Part 2 还给出了配套的 loader 与 **Makefile**，用于同时编译 eBPF 程序与用户态加载器。

---

### 综合总结（两篇一并）

- **Part 1** 建立 eBPF 基础：从 BPF 到 eBPF、验证器与 JIT、与内核模块的取舍、Falco 在云原生下选择 eBPF 的动机；并通过 **syscall tracepoint + ringbuf** 给出从内核到用户态的完整数据路径。  
- **Part 2** 进入**动态插桩**四类探针：用户态入口/返回（uprobe/uretprobe）、内核入口/返回（kprobe/kretprobe），并给出安全分析向的 kprobe 示例（`prepare_kernel_cred`）。  
- 对安全与平台团队而言，这套文章串联了「**系统调用静态 tracepoint**」与「**内核/用户态动态探针**」两条线，是理解 Falco 类工具底层机理的入门读物。

---

## 参考链接

- <https://falco.org/blog/tracing-syscalls-using-ebpf-part-1/>  
- <https://falco.org/blog/tracing-system-calls-using-ebpf-part-2/>  
