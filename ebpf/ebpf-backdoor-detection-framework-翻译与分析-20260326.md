# eBPF 后门检测框架与最新方法论

> 原文链接：[Detection Frameworks and Latest Methodologies for eBPF-Based Backdoors](https://windshock.github.io/en/post/2025-04-29-ebpf-backdoor-detection-framework/)
> 作者：windshock（Code Before Breach）
> 原文发布时间：2025 年 4 月 28 日
> 翻译与分析时间：2026 年 3 月 26 日

---

## 一、文章摘要

本文是关于 eBPF 后门检测的综合性技术报告。eBPF 作为一把双刃剑，在被广泛用于安全监控（如 Falco、Tracee、Tetragon）的同时，也被攻击者滥用于构建极难检测的内核级后门和 Rootkit。文章系统性地梳理了 eBPF 后门的检测挑战、开源检测框架、最新研究趋势（2023-2025）、实战案例以及防御策略。

---

## 二、核心内容翻译与分析

### 2.1 eBPF 后门的兴起与检测挑战

#### eBPF 的双刃剑本质

eBPF 最初用于性能监控和安全策略执行等合法场景，但自 2023 年以来，多个利用 eBPF 的 Rootkit 和恶意软件被发现：

| 恶意工具 | 类型 | 功能 |
|---------|------|------|
| **ebpfkit** | eBPF Rootkit | 综合型 Rootkit，可劫持系统调用、隐藏进程 |
| **TripleCross** | eBPF Rootkit | 多功能 Rootkit，支持后门、隐身、权限提升 |
| **Pamspy** | eBPF 恶意软件 | 利用 uretprobe 劫持 PAM 认证，窃取明文凭据 |
| **BPFDoor** | eBPF 后门 | APT 攻击工具，利用 BPF 过滤器绕过防火墙，被称为"无门后门" |

#### 为什么极难检测？

| 挑战 | 说明 |
|------|------|
| **不作为独立模块存在** | eBPF 程序在内核的 BPF 虚拟机中执行，不像传统内核模块那样可见 |
| **可操纵诊断工具输出** | 活跃的 eBPF Rootkit 可以篡改 `bpftool`、`debugfs` 等工具的输出来隐藏自身 |
| **加载后检测极其困难** | 如果在加载阶段未能检测到，事后发现的难度呈指数级增长——这是**核心难点** |
| **传统杀毒软件完全无效** | eBPF 程序不以文件形式存在于文件系统中，杀毒软件的文件扫描和用户空间监控均无法触及 |

### 2.2 传统 Linux 杀毒为什么无法覆盖 eBPF 后门

**结论：通用 Linux 杀毒软件无法检测或阻止基于 eBPF 的后门。**

| 原因 | 说明 |
|------|------|
| **eBPF 后门不基于文件** | 传统杀毒优化为扫描文件系统中的恶意文件；eBPF 程序加载到内核 BPF 子系统中，不直接存在于文件系统 |
| **无法监控内核内部活动** | 传统杀毒主要监控用户空间进程和磁盘 I/O |
| **信息可能已被篡改** | eBPF Rootkit 可以篡改系统调用、进程列表、文件列表，杀毒软件看到的数据本身可能已被伪造 |
| **无法检测 BPF 级钩子** | 传统杀毒无法捕获系统调用表劫持、kprobe/uprobe 附加等内核级活动 |

> "没有内核级完整性保护，任何输出都不可信。"

### 2.3 Tracee vs LKRG：互补关系

| 维度 | Tracee | LKRG |
|------|--------|------|
| **监控对象** | 内核事件（bpf 调用、execve、open 等） | 内核对象完整性（系统调用表、凭据结构等） |
| **监控时机** | 攻击事件发生时检测 | 内核结构被篡改时检测 |
| **检测焦点** | 系统调用级别 | 内核内存结构级别 |
| **主要目标** | 威胁追踪（发现异常） | 完整性执行与保护 |
| **工作方式** | 被动事件记录与告警 | 主动阻止完整性违规 |
| **本质** | 面向事件响应 | 面向事件预防 |

**类比**：
- **Tracee** 是**安全摄像头**——记录发生的异常活动
- **LKRG** 是**安全栅栏**——主动监控内核结构并阻止篡改

> "只用 Tracee 能记录事件但无法阻止；只用 LKRG 能阻止篡改但不留取证痕迹。**两者结合才是最强保护。**"

### 2.4 开源 eBPF 后门检测框架与工具

| 工具/框架 | 方法与特点 | 备注 |
|----------|----------|------|
| **Tracee（Aqua Security）** | 基于 eBPF 的实时监控工具，捕获 `bpf_attach` 事件（eBPF 程序附加到 kprobe/tracepoint 的瞬间），记录 ID、名称、类型和使用的 helper 函数 | 开源，GitHub 可获取 |
| **ebpfkit-monitor** | Datadog 研究人员开发的专用工具，**静态分析** eBPF 字节码或**监控执行**以检测恶意 eBPF 加载 | 开源，最初为检测 ebpfkit Rootkit 设计 |
| **Falco（CNCF/Sysdig）** | 使用 eBPF 监控系统调用的 HIDS，新版本可**监控 `bpf()` 系统调用**以检测利用 eBPF 的权限提升 | CNCF 开源项目，容器/云环境常用 |
| **bpftool（Linux 原生）** | 内置 BPF 调试/管理工具，列出已加载的 eBPF 程序、Maps 和链接。手动检查可发现可疑 BPF 对象 | Linux 4.x+ 可用，适合手动检查 |
| **Volatility eBPF 插件** | 内存取证工具 Volatility 的插件，从**内存转储**中提取和分析 eBPF 程序，搜索 `prog_idr` 结构，包含分类器判断恶意程序 | 2024 年发布，研究级工具，适合 hypervisor/离线分析 |

### 2.5 最新检测方法论（2023-2025）

#### 方法一：实时加载监控

最有效的检测发生在 **eBPF 程序加载到内核的那一刻**。

- 如果错过了加载事件，后续检测变得极其困难
- EDR/监控工具必须实时监视 `bpf()` 系统调用、kprobe 注册等事件
- Aqua Security 在 Tracee 中集成了 `bpf_attach` 事件监控
- 2023 年 Aqua 检测到 **Pamspy 恶意软件**——通过捕获 `trace_pam_get_a` eBPF 程序的加载事件，识别了明文凭据窃取尝试

#### 方法二：内核完整性检查与加固

在内核中嵌入安全控制以主动阻止 eBPF 后门：

| 加固措施 | 说明 |
|---------|------|
| `CONFIG_BPF_UNPRIV_DEFAULT_OFF` | 禁止非特权用户使用 eBPF |
| 限制 `SYS_bpf` | 仅允许 root 用户使用 |
| 禁用 `CONFIG_BPF_KPROBE_OVERRIDE` | 减少攻击面 |
| 编译时移除 kprobe 功能 | 减少攻击面 |
| `CONFIG_BPF_JIT_ALWAYS_ON` | 最小化 eBPF JIT 被利用的风险 |

#### 方法三：基于 Hypervisor 的审计

宿主机上的检测工具可能被拥有内核权限的 Rootkit **绕过**。因此 2023-2024 年的研究探索了从 Hypervisor 层审计 eBPF 活动：

- **HyperBee 框架**：在客户机 OS 中的 eBPF 程序执行前进行检查
- 2024 年研究：使用轻量级 hypervisor 快照客户机内存，配合 Volatility 插件提取和分类可疑 eBPF helper 函数

#### 方法四：事后检查与威胁追踪

当实时检测失败时，需要手动威胁追踪：

| 检查点 | 命令/位置 |
|--------|---------|
| 检查异常 kprobe | `/sys/kernel/debug/kprobes/list` |
| 列出已加载 eBPF 程序 | `bpftool prog` |
| 检查 BPF 关联的 perf 事件 | `bpftool perf` |
| 检查 XDP 钩子 | `ip link show` |
| 检查 TC 过滤器 | `tc filter show` |
| 检查 BPF 文件系统 | `/sys/fs/bpf/`（pinned objects，用于持久化） |
| 检查系统日志 | `dmesg` 中的 BPF 相关警告 |

### 2.6 实战案例

#### 案例一：BPFDoor 后门

- 2010 年代末发现的 Linux 后门，利用 **cBPF 过滤器**检测特定"魔术包"并为攻击者打开反向 shell
- 绕过防火墙规则，隐藏网络端口——被称为"**无门后门**"
- 2022 年公开曝光，2023 年 APT 攻击者增强了 BPF 过滤器复杂度（增加到原来的 6 倍）
- **Trend Micro** 更新产品检测 BPFDoor 的 BPF 过滤器模式，追踪 `setsockopt` 调用插入 BPF 过滤器的行为

#### 案例二：Pamspy 恶意软件

- 利用 eBPF **uretprobe** 拦截 `libpam.so` 中认证函数的返回值
- Aqua Security 使用 **Tracee** 检测到
- Tracee 日志捕获了钩子函数名（`pam_get_authtok`）和内存偏移等详细信息
- 无需发现隐藏进程即可检测凭据窃取尝试

### 2.7 BPFDoor 检测脚本

文章提供了一个轻量级检测脚本 `bpfdoor_detector.sh`：

```bash
#!/bin/bash
# BPFDoor-like Suspicious Process Detector

if [ "$(id -u)" -ne 0 ]; then
  echo "[!] This script must be run as root."
  exit 1
fi

for pid in $(ls /proc/ | grep -E '^[0-9]+$'); do
  [ -d "/proc/$pid" ] || continue
  exe_path=$(readlink /proc/$pid/exe 2>/dev/null)

  if [[ $exe_path == *"(deleted)" ]]; then
    if [ -r /proc/$pid/net/packet ] && [ -s /proc/$pid/net/packet ]; then
      cmdline=$(ps -p $pid -o cmd= 2>/dev/null)
      if [[ ! $cmdline =~ "tcpdump|wireshark|dhclient" ]]; then
        echo "[!] Suspicious process detected:"
        echo "    - PID: $pid"
        echo "    - Command: $cmdline"
        echo "    - Deleted executable: $exe_path"
        echo "    - BPF socket is active"
        ss -p -n 2>/dev/null | grep "pid=$pid," | awk '{print "    - Network: " $0}'
      fi
    fi
  fi
done
```

检测逻辑：
1. 发现运行中但可执行文件已被删除（`(deleted)` 状态）的进程
2. 过滤出正在使用 BPF socket 的进程
3. 排除合法 BPF 使用者（tcpdump、wireshark、dhclient）

**注意**：高级 eBPF Rootkit 可以篡改 `/proc`，此脚本仅提供轻量级线索。

### 2.8 eBPF 检查脚本（bpftool）

```bash
#!/bin/bash
# 列出所有 BPF 程序
echo "[*] Listing currently loaded BPF programs..."
bpftool prog show

# 列出所有 BPF Maps
echo "[*] Listing currently loaded BPF maps..."
bpftool map show

# 检查 XDP 附加
echo "[*] Checking for XDP programs attached to network interfaces..."
for iface in $(ls /sys/class/net/); do
  ip link show dev "$iface" | grep -q "xdp" && echo "[!] XDP attached: $iface"
done

# 检查 TC 过滤器
echo "[*] Checking for TC filters..."
for iface in $(ls /sys/class/net/); do
  tc filter show dev "$iface" 2>/dev/null | grep -i "bpf" && echo "[!] BPF TC filter detected on: $iface"
done
```

### 2.9 防御策略总结

```mermaid
graph TB
    subgraph "1. 权限管理与加固"
        A1[禁用非必要 eBPF] --> A2[限制 CAP_BPF]
        A2 --> A3[禁用未使用的 kprobe/tracepoint]
    end

    subgraph "2. 实时监控"
        B1[Falco：监控 bpf 系统调用] --> B2[Tracee：内核钩子事件记录]
        B2 --> B3[容器化部署，常驻检测]
    end

    subgraph "3. 定期完整性检查"
        C1[bpftool 定期扫描] --> C2[与上次输出 diff 对比]
        C2 --> C3[检查 /sys/fs/bpf/ 和 kprobes/list]
    end

    subgraph "4. 取证能力准备"
        D1[内存转储能力] --> D2[Hypervisor 快照]
        D2 --> D3[Volatility 插件分析]
    end

    subgraph "5. 持续情报更新"
        E1[跟踪最新博客/会议] --> E2[整合新 IOC 和检测规则]
    end
```

---

## 三、与本系列的关联分析

### 3.1 攻防视角的对照

本系列之前的文章全部是从**防御者/监控者**视角出发——用 eBPF 来检测文件变更、捕获系统调用、保护文件完整性。而这篇文章揭示了**硬币的另一面**——攻击者同样利用 eBPF 来实现后门和 Rootkit。

| 视角 | 代表方案 | 使用 eBPF 的目的 |
|------|---------|-----------------|
| **防御者** | Falco、Tetragon、Sysdig、Datadog、Wazuh | FIM、HIDS、运行时安全 |
| **攻击者** | BPFDoor、ebpfkit、TripleCross、Pamspy | 后门、Rootkit、凭据窃取 |

### 3.2 "eBPF 监控 eBPF"的信任问题

这篇文章揭示了一个深层悖论：

- Falco/Tracee 等工具**本身就基于 eBPF**
- 但 eBPF Rootkit 可以**篡改这些工具的输出**
- 因此，如果 Rootkit 已经活跃，基于 eBPF 的检测工具本身也不可信

**解决方案路径**：

| 方案 | 可信度 | 实用性 |
|------|--------|--------|
| eBPF 工具（Tracee/Falco） | 中（可被篡改） | 高（易部署） |
| 内核完整性保护（LKRG） | 高（内核结构级） | 中（需内核模块） |
| Hypervisor 审计 | 最高（外部视角） | 低（需 hypervisor 支持） |
| 内存取证（Volatility） | 高（离线分析） | 低（事后） |

### 3.3 对 FIM 系统的安全启示

| 威胁 | 说明 | 影响的 FIM 方案 |
|------|------|---------------|
| eBPF Rootkit 篡改 FIM 输出 | Rootkit 可拦截 FIM 的系统调用，伪造"一切正常" | 所有基于 eBPF 的 FIM |
| BPFDoor 绕过网络监控 | 利用 BPF 过滤器隐藏网络端口 | 网络层检测 |
| 攻击者利用 kprobe 拦截 VFS 调用 | 与 FIM 使用相同的钩子点，但用于隐藏文件操作 | Kprobe 型 FIM（Sysdig、fs-watcher） |

**关键启示**：构建 FIM 系统时，不能只考虑"如何检测文件变更"，还必须考虑"如何确保检测系统本身未被篡改"。LKRG + Tracee 的组合方案，或 Hypervisor 级审计，是应对这一信任问题的必要补充。

---

## 四、关键技术要点总结

### 4.1 eBPF 后门检测的核心原则

1. **加载时检测是最有效的**——错过加载事件后，检测难度呈指数级增长
2. **不能信任被入侵系统的任何输出**——需要外部验证（hypervisor/内存取证）
3. **静态分析 + 动态监控互补**——ebpfkit-monitor 的静态分析 + Tracee 的实时监控
4. **多层防御是必须的**——权限加固 + 实时监控 + 定期检查 + 取证能力

### 4.2 实用检查清单

| 检查项 | 命令 | 异常信号 |
|--------|------|---------|
| 已加载 eBPF 程序 | `bpftool prog show` | 未知的 kprobe/tracepoint 类型程序 |
| BPF Maps | `bpftool map show` | 异常大的 Map 或未知 Map |
| XDP 附加 | `ip link show` | 意外的 XDP 程序 |
| TC 过滤器 | `tc filter show dev <iface>` | BPF TC 过滤器 |
| kprobe 列表 | `cat /sys/kernel/debug/kprobes/list` | 钩在敏感函数上的探针 |
| BPF 文件系统 | `ls /sys/fs/bpf/` | 未知的 pinned objects |
| 已删除的可执行文件 | `readlink /proc/<pid>/exe` | `(deleted)` 状态 + BPF socket 活跃 |
| 系统日志 | `dmesg \| grep -i bpf` | BPF 相关警告 |

---

## 五、总结

这篇文章是**eBPF 安全攻防的全景式综述**，其核心价值在于：

1. **揭示了 eBPF 的双刃剑本质**——同一技术既是最强大的安全工具，也是最隐蔽的攻击武器
2. **系统化梳理了检测框架**——Tracee、Falco、ebpfkit-monitor、bpftool、Volatility 各有定位
3. **提出了分层信任模型**——从 eBPF 自身监控到 LKRG 内核保护到 Hypervisor 外部审计
4. **给出了实用脚本和检查清单**——可直接用于生产环境的安全检查
5. **真实案例驱动**——BPFDoor 和 Pamspy 的检测过程提供了实战参考

对于本系列的 FIM 研究而言，这篇文章提供了一个至关重要的**威胁模型补充**：**如果你的 FIM 系统基于 eBPF，那么你还需要确保 eBPF 本身没有被攻击者利用来颠覆你的监控。**
