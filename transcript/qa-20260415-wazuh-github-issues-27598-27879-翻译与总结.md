# Wazuh GitHub Issues #27598 / #27879 翻译与总结

> 日期：2026-04-15  
> 来源：[#27598 FIM whodata eBPF](https://github.com/wazuh/wazuh/issues/27598) · [#27879 FIM whodata eBPF: Development](https://github.com/wazuh/wazuh/issues/27879)

---

## 会话概要

用户请求对 Wazuh 仓库中两个与 **FIM（文件完整性监控）who-data + eBPF** 相关的 Issue 进行中文翻译与要点总结。#27598 为功能目标与需求规格；#27879 为开发实施 Epic，含架构、挑战与完成定义，二者均已关闭（完成）。

---

## Issue #27598 — FIM whodata eBPF

**状态：** 已关闭（2025-04-03）  
**类型：** 增强 · FIM / whodata · Linux  
**作者：** vikman90（成员）

### 中文摘要

为增强 Linux 上 FIM 的 **who-data**（带用户与进程上下文的实时文件变更监控），提案在 **eBPF** 上实现 who-data；在 eBPF 与 Audit 均不可用时，自动回退到 **inotify** 实时模式（无进程/用户上下文）。

### 功能需求要点

1. **回退顺序（who-data 场景）：** 优先 Audit 的表述与后续条目需结合全文理解——正文明确写的是：配置 who-data 时 **优先使用 eBPF**；eBPF 不可用时回退 **Audit**；二者都不可用时回退 **inotify**（无 who-data）。
2. **与现有 auditd who-data 能力对齐：** 监控目录及子目录内变更；覆盖新建/修改/删除文件、目录重命名、目录删除；**排除**「新建目录」事件；每条事件需含路径、变更类型、**UID/用户名**、**PID/进程名**。
3. **FIM 状态字段与告警字段**不得因本特性而改变数量或类型。
4. **可配置首选提供者：** **eBPF** 或 **Audit**（默认），在 `<whodata><provider>ebpf</provider></whodata>` 等形式中声明（与 `<directories whodata="yes">` 配合）。

### 非功能需求

- 支持多发行版（RHEL 9、CentOS Stream 9/10、Debian 11/12、Ubuntu 20.04/22.04/24.04、Oracle Linux 9、AL2023、openSUSE/SUSE 15 等）；**内核低于 5.8 的不支持**（文中划掉了更老发行版列表）。
- EPS 至多不超过既有实现；主机资源消耗不得高于当前实现。

### 实现约束

- **模块化、C++** 实现；面向 **Wazuh 4.x**，并需可迁移到 **5.x**。
- **术语：** eBPF 与 Audit 作为 who-data 的 **「提供者（providers）」**，与 FIM 的 **模式（scheduled / realtime / whodata）** 区分。

### 计划阶段

Spike/PoC → 开发（eBPF 驱动、回退与集成、测试）→ 文档 → QA/性能测试适配。

---

## Issue #27879 — FIM whodata eBPF: Development

**状态：** 已关闭（2025-04-01）  
**类型：** 增强 · Epic（子任务级） · FIM / whodata · Linux  
**作者：** jotacarma90（成员）

### 中文摘要

本 Issue 聚焦 **who-data 的 eBPF 驱动开发**：在 **内核 5.8+** 上提供高性能、模块化、可维护的实时文件监控并采集 who-data；eBPF 逻辑需封装为**动态库**，而非与 FIM 单体耦合。

### 需求要点

1. **Linux Kernel 5.8+**。
2. **模块化：** eBPF 封装在**动态库**中。
3. **功能对齐 Audit who-data：** 文件创建/修改/删除/重命名；采集 UID、PID、进程名等 actor 信息。
4. **性能：** 降低内核开销、通过过滤减少无效路径与噪声、相对 Audit 驱动控制 EPS 额外开销。
5. **回退：** 有 eBPF 则优先；否则 Audit；再否则 inotify（无 who-data）。
6. 在**所有支持的 Linux 发行版**上测试。

### BPF 驱动架构（原文含 mermaid）

- **内核侧：** 对 `open`、`setattr`、`unlink` 等 hook，配合 **FD 表**、**缓冲区**。
- **用户态 FIM：** Dispatch → **BPF Provider**（路径过滤 **Filter Path**、缓冲区）→ 派发。

### 挑战（译文要点）

1. **eBPF 接入方式：** 评估后采用 **预编译 eBPF、面向 Linux 5.8+**，随 Agent 发布单一版本，避免在 Agent 内编译或为每个内核单独打包。
2. **信息采集：** eBPF 是受限内核入口；`open` 路径较直接；`write` 等仅有 fd 时需解析路径；工作目录等需遍历内核结构拼绝对路径。
3. **性能：** 预过滤（如排除 `/proc` 等噪声）；BPF 内产生较全量事件，**未监控路径的过滤在用户态做**以降低内核负担；思路与 **Falco** 类似（内核 raw 事件 + 外部过滤），并注意避免 Falco 类事件丢弃问题。

### Definition of Done（原文均为已勾选）

- eBPF 驱动已在 FIM 中实现；预编译 BPF、**5.8+**；**动态库**形态；单元/集成/性能测试通过；文档含设计、配置、基准与已知限制。

### 说明

#27879 正文含大量 **开发过程更新**（研究 Falco libs、BCC、CO-RE/BTF、编译与 CI 问题等），上述为**主描述与 DoD** 层面的翻译与归纳；细节以 Issue 内时间线评论为准。

---

## 两则 Issue 的关系（总结）

| 维度 | #27598 | #27879 |
|------|--------|--------|
| 定位 | 产品/功能目标与需求规格（含 XML 配置示例、发行版列表） | 开发 Epic：驱动架构、技术挑战、DoD |
| 关系 | 总目标与约束 | 实现落地与验收 |

二者共同指向：**Linux FIM who-data 增加 eBPF 提供者，与 Audit/inotify 形成可配置回退链**，并在约 2025 年 Q1 末前关闭。
