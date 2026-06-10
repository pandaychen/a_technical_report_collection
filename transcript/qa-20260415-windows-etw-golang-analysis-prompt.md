# 技术对话记录：Windows ETW（Golang）项目代码分析提示词

> 日期：2026-04-15  
> 会话主题：生成用于分析基于 Golang 的 Windows ETW 项目的详细提示词（含事件字段、进程/线程、PowerShell 审计维度）  
> 参与方：用户 + Claude Code

---

## 会话概要

用户需要一份可复用的「项目代码分析提示词」，面向使用 Golang 实现的 Windows ETW 采集/审计类项目。除通用架构与 Go 侧实现外，需重点覆盖：已订阅/采集的 ETW Provider 与事件类型、字段级说明、进程与线程相关事件的字段清单，以及是否具备 PowerShell 脚本内容级采集与审计能力。本文档同时给出可直接复制给 AI 或人工审查使用的完整提示词正文。

---

## 详细对话记录

### Q1: 生成 Windows ETW（Golang）项目分析提示词

**用户提问：**

> 正在分析一个使用 Golang 实现的 Windows ETW 项目。请作为一名 Windows 内核开发专家和高级 Go 语言架构师，帮助生成一段详细的项目代码分析提示词。除通用分析外，还需额外理解：
> 1. 采集了哪些事件，详细的字段及说明是什么？
> 2. 采集的进程/线程相关的事件包含了哪些详细的字段？
> 3. 是否支持对 PowerShell 脚本内容的采集审计？

**结论/输出：**

以下提示词可直接作为对代码库或 AI 助手的「分析任务说明」使用。

---

## 附录：可复制使用的完整提示词

```markdown
# 角色设定

你是一名 **Windows 内核与诊断基础设施专家**（熟悉 ETW、WDM/WDF 周边用户态组件、事件模型与性能计数器），同时也是一名 **高级 Go 语言架构师**（熟悉 Go 模块结构、并发模型、错误处理、Windows  syscall/CGO、以及常见可观测性工程实践）。

请对当前代码仓库中 **基于 Golang 实现的 Windows ETW（Event Tracing for Windows）相关项目** 进行系统性代码分析，输出结构化结论。**所有结论必须能在代码或配置中找到依据**；若仅有推断，请明确标注「推断」并说明需要运行时或文档验证的步骤。

---

# 分析目标

在通读项目的前提下，完成从「入口 → 会话/控制器 → Provider/事件订阅 → 解析与序列化 → 存储/转发/消费」的完整链路说明，并单独深入以下三个方面（见下文「必答专项」）。

---

# 一、项目与架构（通用）

1. **项目边界**
   - 主程序入口、可执行目标、构建方式（`go build`、tags、CGO 等）。
   - 是否包含多二进制、sidecar、配置分层（dev/prod）。

2. **模块划分**
   - 按目录/包说明职责：ETW 控制、会话管理、回调解析、模型定义、输出适配器（文件、Kafka、gRPC、Windows Event Log 等）。
   - 依赖关系图（文字或 Mermaid）：谁依赖谁，避免循环依赖的位置。

3. **ETW 控制面实现路径**
   - 使用哪些 Windows API 或封装库（例如：`StartTrace`/`ControlTrace`/`EnableTraceEx2`、`OpenTrace`/`ProcessTrace`、`Tdh*`、`wevtapi` 等；或纯 Go 封装）。
   - **Trace 会话**：Session 名称、GUID、日志文件模式 vs 实时 consumer、缓冲区与刷新策略（若代码中有）。
   - **Provider 启用**：通过哪些 Provider GUID、Keyword、Level、Property 启用；是否在代码中硬编码或可配置。

4. **数据面与并发**
   - 事件回调线程模型：`ProcessTrace` 阻塞、goroutine、channel、背压策略。
   - 解析路径：同步解析 vs worker pool；大事件或高 QPS 下的限流/丢弃策略（若有）。

5. **错误处理与可运维性**
   - 典型失败场景：权限不足、会话冲突、内核缓冲区丢失（lost events）、解析失败。
   - 日志、指标、健康检查（若有）。

6. **安全与合规**
   - 是否采集敏感字段（命令行、用户 SID、脚本内容）；脱敏、最小权限运行方式。
   - 以何种身份运行（LocalSystem / 管理员 / 受限用户）及文档/代码依据。

---

# 二、必答专项 A：采集了哪些事件？字段级清单与说明

请基于代码与内嵌/外部清单（manifest、XML、JSON、常量表）回答，并给出**可追溯引用**（包名、文件、常量名或配置键）。

1. **Provider 与事件清单**
   - 列出所有 **Provider GUID**（或友好名称若代码中映射）及用途简述。
   - 对每个 Provider，列出实际 **Enable** 的 **Keyword / Level** 组合（若存在多套 profile，分别说明）。

2. **事件类型枚举**
   - 列出订阅到的 **Event ID** 或 **Opcode/Task**（以代码中实际解析路径为准：Tdh、手动结构体、或预生成 schema）。
   - 说明哪些事件来自 **Microsoft-Windows-* 内置 Provider**，哪些是 **自定义 Provider**。

3. **字段级说明（核心）**
   - 对每一类「业务上有意义」的事件，给出表格或列表：
     - 字段名（代码中的名字 + 若可对应 ETW 属性名）
     - 类型（string/uint/sid/guid/binary/time）
     - 含义与典型取值
     - 是否可能为空、是否需二次解析（如十六进制 blob）
   - 若项目将原始属性映射为内部 struct，请给出 **struct 定义** 与 **ETW 属性** 的对应关系说明。

4. **丢失与完整性**
   - 代码是否处理 `EVENT_TRACE_FLAG`、丢失计数、或 `EVENT_HEADER` 中的标志位；如何暴露给运维。

---

# 三、必答专项 B：进程 / 线程相关事件的详细字段

请将「进程/线程」相关事件单独成章（即使它们混在其他 Provider 中）。

1. **覆盖范围**
   - 是否包含：`Process Start/Stop`、`Thread Start/Stop`、`Image Load`、句柄、远程线程注入相关（若代码有针对性订阅）。
   - 对应 **Provider 名称/GUID** 与 **Event ID**。

2. **字段清单（必须细化）**
   - 进程：`ProcessId`、`ParentProcessId`、`ImageFileName`/`ImagePath`、`CommandLine`、`SessionId`、`User SID`、`Integrity Level`（若有）、创建时间等——**以代码实际解析到的为准**，勿凭常识补全未实现字段。
   - 线程：`ThreadId`、`ProcessId`、起始地址、用户/内核栈（若采集）、创建者等。
   - 若存在 **字段拼接、规范化路径、去重键**（例如把短路径扩成完整路径），说明算法位置。

3. **关联关系**
   - 进程树是否可在代码中重建；使用哪些事件顺序与字段作为父进程推断依据。

---

# 四、必答专项 C：是否支持 PowerShell 脚本内容的采集与审计

请明确回答「支持 / 部分支持 / 不支持」，并给出证据链。

1. **脚本内容级证据**
   - 是否订阅 **Microsoft-Windows-PowerShell/Operational** 或 **Script Block Logging** 相关事件（例如事件 ID 与字段中是否包含 `ScriptBlockText` 或等价载荷）。
   - 或是否通过 **Module Logging**、**Transcription**、其他 ETW 路径间接获得脚本片段。

2. **实现位置**
   - 解析脚本内容的函数/文件；是否截断、分块、编码（Unicode/Base64）。

3. **策略与风险**
   - 是否依赖组策略/注册表开启脚本日志；未开启时的降级行为。
   - 隐私与存储：是否哈希、采样、按用户脱敏。

4. **若不支持**
   - 说明代码中**缺少**哪些 Provider/Keyword/解析逻辑；若要支持，列出需要增加的最小改动点（仅作设计建议，标注为「建议」而非「已实现」）。

---

# 五、交付物格式

请按以下结构输出最终报告：

1. **执行摘要**（10～15 行）
2. **架构与数据流**（含 Mermaid：从 ETW 到输出的主路径）
3. **事件与字段总表**（可分附录）
4. **进程/线程专题**
5. **PowerShell 审计结论**（支持度分级 + 证据）
6. **配置样例**（若仓库有）
7. **未决问题与验证清单**（需要在本机启用哪些日志、如何用 `logman`/`wevtutil` 对照验证）

---

# 约束

- 以代码为准；官方文档仅作辅助解释已实现的语义。
- 区分「Windows 版本差异」：若代码中有 build tag 或运行时版本分支，请写明。
- 中文撰写，专有名词保留英文（ETW、Provider、Keyword、Tdh 等）。
```

---

## 生成的产物清单

| # | 文件名 | 类型 | 说明 |
|---|--------|------|------|
| 1 | `transcript/qa-20260415-windows-etw-golang-analysis-prompt.md` | 文档 | 会话记录 + 可复制提示词全文 |

## 后续待办

- [ ] 将上述提示词用于具体仓库分析时，把「Provider GUID / 事件 ID / struct 映射」表与代码引用一并填实
- [ ] 若需验证 PowerShell 脚本块采集，在目标环境对照组策略与 `Get-WinEvent` 抽样核对
