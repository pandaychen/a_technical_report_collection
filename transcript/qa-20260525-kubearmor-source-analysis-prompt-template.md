# KubeArmor 全生态源码级分析提示词模版 技术对话记录

> 日期：2026-05-25
> 会话主题：为 KubeArmor 全生态（daemon/operator/controller/relay/CLI/init）源码级分析定制专用提示词模版
> 产出物：`ebpf/kubearmor-source-analysis-prompt-template-20260525.md`
> 参考模版：`ebpf/cursor-ebpf-project-analysis-prompt-template.md`（八阶段通用版）、`transcript/qa-20260419-deepwiki-blog-prompt-template.md`（DeepWiki 博客版）

---

## 会话概要

用户计划对 KubeArmor（内核态 C + 用户态 Go）进行源码级深度分析，需要一份量身定制的提示词模版，满足以下需求：

1. 覆盖全生态 6 个仓库/子模块（daemon、operator、controller、relay、CLI、init）
2. 以「主提示词 + 可选附加模块」混合形态交付（hybrid）
3. 本地 clone 源码引用 + GitHub 永久链接双重支撑
4. 最终引导大模型产出一篇万字级专业中文 Markdown 文档
5. 核心问题聚焦于：Hook 全景、内核态/用户态数据关联、容器富化主线、CRD/Operator/InitContainer 部署实现

经过三轮澄清问答后完成模版设计与交付。

---

## 详细对话记录

### Q1：用户初始需求

**用户提问：**

> 我现在要对 kubearmor 项目（内核态 c、用户态 g）进行源码级别的分析，请为我生成提示词，使用中文，要求能够直观的了解到项目目的和实现原理，最终生成一盘详细且专业的 markdown 文档。
>
> 项目支持哪些核心功能？亮点是什么？
>
> 代码实现篇：
> 1. 项目使用了哪些 hook？
> 2. 这些 hook 在内核态的数据是否有关联，目的何用？
> 3. 这些 hook 在用户态的数据是否有关联，目的何用？
>
> 原理分析篇：
> 1. 容器，ebpf 在内核态产生的数据是如何在用户态，结合 kubernetes api 或者 docker cri，进行丰富化和关联起来的？依赖的核心关键因子是什么？结合代码进行详细分析
> 2. 整个系统实现，是如何部署在容器中的，拆分为哪些组件？以何种方式部署？比如 daemonset、operator 的实现细节是什么？采用了脚手架还是直接对接 api 实现的？项目使用了 initcontainer 了吗？目的是什么？如何实现的？
> 3. 项目是否使用了 crd（cr），使用 crd 的目的是什么？cr 的实例化，属于什么级别的？
> 4. 项目分为哪些模块？从部署视角来看，详细分析各个模块的运行过程，并给出 mermaid 图
>
> 其他需要补充的地方，你帮我补充完整，目的就是为了更加深入的了解项目实现（像是项目的作者就是你本人一样），有问题的话先向我提问

**分析过程：**

- 识别到 KubeArmor 是一个多仓库生态项目（daemon + operator + controller + relay + CLI），用户的问题涵盖了从内核 Hook 到 K8s 部署的全栈分析需求
- 现有的通用八阶段模版虽然覆盖面广，但对 KubeArmor 的特殊性（LSM 多后端、CRD-native、Operator-driven）缺乏针对性
- 需要先与用户对齐三个关键决策点再开始撰写

---

### Q2：三轮澄清问答

**AI 提问 1 — 分析范围：**

> KubeArmor 提示词的「分析范围」期望覆盖哪些仓库？

**用户选择：** **全生态** — daemon + operator + controller(admission) + relay + karmor CLI + kubearmor-init

**AI 提问 2 — 产出形态：**

> 提示词的「产出形态」期望是哪一种？

**用户选择：** **混合形态（hybrid）** — 一段主提示词产出一篇综合长文 + 若干可选「附加追问」模块（部署/CRD/数据关联等可选深挖），同时给 Mermaid 与 draw.io 节点清单

**AI 提问 3 — 代码引用方式：**

> 提示词中是否假设代码已经 clone 到本地？

**用户选择：** **二者皆要求** — 本地 clone 优先，同时硬性要求每条关键结论附 GitHub 永久链接，便于落盘文档可被外部验证

---

### Q3：提示词设计方案确认

**AI 输出：** 给出了完整的 Plan 设计方案（见附属 plan 文件），包含以下核心设计决策：

1. **元信息块**：角色定义为 eBPF + Linux 内核 + K8s Operator + 容器运行时安全四栖专家
2. **范围圈定**：6 个仓库/子模块的 ref 锁定 + 判定规则（如 operator 独立仓库与主仓 `pkg/KubeArmorOperator/` 的二选一判定）
3. **双引用规则**：本地相对路径 + GitHub `blob/<commit-sha>/path#Lxx-Lyy` 永久链接
4. **强制章节清单**（对齐用户原始问题）：
   - `0x00 前言`：版本锁定 + 先读结论
   - `0x01 项目目的与核心能力亮点`：白名单语义、LSM 多后端、CRD 声明式
   - `0x02 代码实现篇 — Hook 全景`：Hook 清单表 + 内核态数据关联 + 用户态数据关联
   - `0x03 原理分析篇`：容器富化主线（cgroup/runtime/informer/关键因子）+ 部署架构（DaemonSet/Operator/InitContainer 三连问）+ CRD 全景 + 模块运行时序
   - `0x04 数据流与生产-消费模型`：源-中介-汇三段式 + CAP/一致性语义
   - `0x05 安全与对抗`：多 enforcer 降级 + MITRE ATT&CK 覆盖 + 绕过分析
   - `0x06 性能与可维护性`
   - `0xFF 参考与链接` + draw.io 节点清单
5. **可选附加模块**（5 个）：
   - A — BPF-LSM 内核代码深读
   - B — Operator/InitContainer 走读
   - C — CRD Schema 演进
   - D — 与 Tetragon/Falco 横向对比
   - E — Helm vs Operator 部署对比
6. **4 张必须 Mermaid 图**：架构图、部署拓扑图、Hook 数据流图、容器富化时序图
7. **自检清单**：9 条发布前 checklist

**用户确认：** Plan accepted

---

### Q4：提示词交付

**AI 输出：** 在 `ebpf/kubearmor-source-analysis-prompt-template-20260525.md` 中交付完整提示词模版，结构如下：

| 章节 | 内容 |
|------|------|
| 一、使用说明 | clone 命令、使用步骤、交叉验证方法 |
| 二、主提示词（可复制） | 角色定义 + 范围锁定 + 写作版式 + 引用规则 + Mermaid 规范 + 强制章节清单（0x00 至 0xFF）+ 输出格式 |
| 三、可选附加模块 | 5 个附加段落（A-E），按需拼接 |
| 四、可选参数 | 篇幅控制、英文摘要、draw.io、竞品对比 |
| 五、Mermaid 示例骨架 | 整体架构图 + 容器富化时序图（可供模型仿写） |
| 六、自检清单 | 9 条 checklist |
| 七、使用技巧 | 7 条实操建议 |

---

## 关键设计决策记录

| 决策点 | 选择 | 理由 |
|-------|------|------|
| 产出形态 | 混合（主提示词 + 附加模块） | 用户需求同时覆盖广度（全生态）和深度（特定子系统），hybrid 最灵活 |
| 代码引用方式 | 本地路径 + GitHub 永久链接双重 | 本地优先利于 Cursor @引用，GitHub 链接便于文档外部可验证 |
| 分析范围 | 全生态 6 个仓库/子模块 | 用户明确需要理解 Operator/Controller/Relay 的实现细节 |
| 容器富化主线 | 作为 0x03.1 独立核心章节 | 这是用户原始问题中最强调的一项，需要逐一对照源码 |
| Operator 脚手架判定 | 强制要求 go.mod 级证据 | 避免模型含糊回答，必须给出 controller-runtime / operator-sdk / kubebuilder 的精确判定 |
| InitContainer | 三连问强制回答 | 用户原始问题明确提出，且 KubeArmor 的 init 逻辑（LSM 探测/AppArmor 预热）是架构理解的关键 |
| Mermaid 图数量 | 至少 4 张 | 架构、部署、Hook 数据流、容器富化时序各一张，覆盖用户全部可视化需求 |
| 章节风格 | 0x00/0x01 十六进制 | 沿用用户仓库已有的博客版式习惯（参考 deepwiki 模版） |

---

## 使用的 Skills

- `ebpf-project-analysis`：参考八阶段分析框架，定制 KubeArmor 特化版本
- `save-qa-record`：保存本次对话记录

---

## 相关文件

| 文件 | 用途 |
|------|------|
| `ebpf/kubearmor-source-analysis-prompt-template-20260525.md` | 本次交付的提示词模版 |
| `ebpf/cursor-ebpf-project-analysis-prompt-template.md` | 通用八阶段模版（参考） |
| `transcript/qa-20260419-deepwiki-blog-prompt-template.md` | DeepWiki 博客模版（参考） |
| `transcript/qa-20260409-ebpf-kubernetes-security-observability-projects.md` | KubeArmor 项目简介（参考） |
