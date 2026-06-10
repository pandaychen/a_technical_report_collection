# 构建文件系统监视器的兔子洞之旅

> 原文链接：[The Rabbit Hole of Building a Filesystem Watcher](https://amandeepsp.github.io/blog/fs-watcher/)
> 作者：Amandeep Singh
> 原文发布时间：2025 年 9 月 23 日
> 翻译与分析时间：2026 年 3 月 26 日

---

## 一、文章摘要

作者在运维高度定制化环境时遇到一个实际问题：运维人员以 root 身份在服务目录下执行命令，导致文件所有者变更，服务重启失败。虽然有简单的解决方案（文件权限、ACL、SELinux），但作者决定自己动手构建一个文件系统事件监视器作为技术探索。文章记录了从 fanotify 到 eBPF 的两次尝试，展示了在 eBPF 中遍历目录树、处理验证器限制以及 LSM 钩子等实战经验。

---

## 二、核心内容翻译与分析

### 2.1 问题背景

- 系统中某些服务要求其管理的所有文件和目录必须归属特定用户
- 运维人员有时以 root 身份在服务目录下执行命令，改变了文件所有者
- 服务运行期间不受影响，但**无法重启**
- 修复很简单（`chown -R`），但作者希望**自动检测**这类变更

### 2.2 第一次尝试：fanotify

fanotify 是 Linux 内核提供的文件系统事件通知 API：
1. 通过 `fanotify_init` 创建内核态通知组
2. 通过 `fanotify_mark` 设置监控目录
3. 通过读取文件描述符获取事件

**遇到的问题**：

| 问题 | 说明 |
|------|------|
| **无法递归监控目录** | 递归监控仅支持整个文件系统挂载点，无法针对单个目录递归 |
| **缺少完整凭据信息** | 事件仅包含触发进程的 PID，没有 UID/GID。需要额外读取 `/proc/<pid>/status` 获取用户信息——每个事件都要打开并解析一个 proc 文件 |

### 2.3 第二次尝试：eBPF

作者在使用 Falco 的过程中接触到 eBPF，决定用它来解决问题。

#### 工具链的进化

作者庆幸自己赶上了 eBPF 工具链成熟的时代：

| 早期痛点 | 现代解决方案 |
|----------|-------------|
| 需要本地内核源码编译 eBPF 程序 | **BTF**（BPF Type Format）提供轻量级类型信息 |
| 需要在目标服务器上编译 | **CO-RE**（Compile Once - Run Everywhere）一次编译到处运行 |
| 加载器复杂 | **libbpf** 简化了加载流程 |

#### 钩子选择：VFS 层函数

作者选择钩入内核 VFS（虚拟文件系统）层函数，如 `vfs_mkdir`、`vfs_create`。

优势：
- VFS 抽象了各种文件系统实现，提供统一接口
- 可以在内核中读取参数并过滤事件，减少上下文切换

**遇到的问题**：

| 问题 | 说明 |
|------|------|
| **ABI 不稳定** | kprobe 钩入 `vfs_*` 函数不保证稳定 ABI，参数可能变化，函数可能消失。在标准化环境中问题不大，但需要工程投入（可通过 BPF CO-RE 解决） |
| **需要在内核中实现路径过滤** | `vfs_*` 探针会被**所有**事件触发，必须在 eBPF 中遍历文件系统树判断是否在监控目录内。受限于禁止无界循环和 512 字节栈大小 |

#### 在 eBPF 中遍历目录树

核心实现——通过 `dentry` 结构体向上遍历目录树，检查是否在监控目录内：

```c
static bool is_monitored_dir(struct dentry *dentry, __u64 target_ino) {
  bpf_rcu_read_lock();
  struct dentry *curr_dentry = BPF_CORE_READ(dentry, d_parent);
  struct inode *curr_inode;
  __u64 curr_ino;
  bool result = false;

  #pragma unroll
  for(int i = 0; i < MAX_DEPTH; i++) {
    if (!curr_dentry) break;

    curr_inode = BPF_CORE_READ(curr_dentry, d_inode);
    curr_ino = BPF_CORE_READ(curr_inode, i_ino);
    if (curr_ino == target_ino) {
      result = true;
      break;
    }

    struct dentry *parent_dentry = BPF_CORE_READ(curr_dentry, d_parent);
    if (curr_dentry == parent_dentry) {
      break;  // 到达树根
    }
    curr_dentry = parent_dentry;
  }

  bpf_rcu_read_unlock();
  return result;
}
```

**关键技术点**：

| 技术点 | 说明 |
|--------|------|
| `#pragma unroll` | 告诉编译器展开循环，满足验证器对有界循环的要求 |
| `MAX_DEPTH` | 有限深度截断，因为 eBPF 不允许无界循环 |
| `BPF_CORE_READ` | CO-RE 宏，确保跨内核版本读取结构体字段时自动适配偏移 |
| `bpf_rcu_read_lock/unlock` | RCU 读锁保护——dentry 树可能在遍历过程中被修改，RCU 让读者安全遍历且不阻塞写者 |
| **inode 号比较** | 使用 inode 号（而非路径字符串）判断是否是目标目录，避免了字符串比较的复杂性 |

#### 更好的钩子：LSM Hooks

作者提到 **LSM（Linux Security Module）钩子**是更优的选择：

| 维度 | VFS kprobe | LSM 钩子 |
|------|-----------|---------|
| ABI 稳定性 | ❌ 不保证 | ✅ 更稳定，语义明确 |
| 事件噪声 | 高（所有 VFS 操作都触发） | 低（安全相关操作才触发） |
| 路径解析 | 需手动遍历 dentry 链 | 可通过 `bpf_path_d_path` 直接获取路径字符串 |
| 可用性 | 广泛支持 | 需要较新内核 |

作者因为当前内核版本不支持 LSM 钩子而未能使用，计划在基础设施升级后尝试。

> 这与 Tetragon 的方案不谋而合——Tetragon 正是钩入 `security_file_permission` 等 LSM 函数来实现 FIM。

---

## 三、核心技术要点总结

### 3.1 方案演进路径

```mermaid
graph LR
    A[fanotify] -->|无法递归监控<br/>缺少用户信息| B[eBPF + VFS kprobe]
    B -->|ABI 不稳定<br/>需内核路径过滤| C[eBPF + LSM 钩子<br/>未来方向]
    
    style A fill:#FFB6C1
    style B fill:#FFD700
    style C fill:#90EE90
```

### 3.2 实战经验

| 经验 | 内容 |
|------|------|
| **inode 号比较优于路径字符串** | 在 eBPF 有限栈空间中，比较 `u64` 的 inode 号远比字符串操作高效和安全 |
| **CO-RE 是现代 eBPF 的基础** | `BPF_CORE_READ` 解决了跨内核版本的结构体字段访问问题 |
| **RCU 锁不可忘** | dentry 树是动态变化的，遍历必须在 RCU 读锁保护下进行 |
| **有界循环是必须的** | `MAX_DEPTH` 配合 `#pragma unroll` 满足验证器要求 |
| **LSM 钩子是更优方向** | 更稳定的 ABI、更少的事件噪声、更便捷的路径解析 |

---

## 四、与本系列其他文章的关联

| 主题 | 本文 | Joel Schumacher 文章 | Tetragon |
|------|------|---------------------|----------|
| 钩子选择 | VFS 函数（`vfs_mkdir` 等） | VFS 函数（6 个） | LSM 函数（`security_file_*`） |
| 路径解析 | inode 号比较 | dentry 链遍历 + 挂载命名空间 ID | `struct file` 中提取路径 |
| ABI 稳定性 | 用 CO-RE 缓解 | 手动定义结构体 | 框架封装 |
| 验证器挑战 | `#pragma unroll` + `MAX_DEPTH` | 缓冲区加倍 + 位掩码 | 框架封装 |
| LSM 钩子 | 认为是更优方向但未使用 | 未涉及 | 核心方案 |

**关键洞察**：三位独立开发者/团队从不同场景出发，最终都指向了同一个技术演进方向——**LSM 钩子是 eBPF 文件监控的最优钩子位置**。这不是巧合，而是因为 LSM 钩子在 ABI 稳定性、语义明确性和路径信息完整性上都显著优于 VFS 层 kprobe。

---

## 五、个人思考

### 5.1 文章的价值

这篇文章虽然篇幅不长，但有几个亮点：

1. **真实的需求驱动**——从一个具体的运维问题出发，而非为了技术而技术
2. **清晰的演进思路**——fanotify → eBPF VFS → LSM 钩子的渐进探索路径
3. **inode 号比较的巧妙设计**——避免了在 eBPF 中处理字符串的复杂性，这是一个值得学习的技巧
4. **RCU 锁的正确使用**——很多 eBPF 文章忽略了 dentry 遍历需要 RCU 保护这一点

### 5.2 与系列总结的关系

到目前为止，本系列已经形成了 eBPF 文件监控的**完整知识图谱**：

| 层次 | 代表文章/方案 |
|------|-------------|
| **理论基础** | Sysdig eBPF 系列（验证器、Helper、Maps） |
| **商业方案** | Tetragon（LSM 钩子 + Inode-based）、Sysdig FIM、Wazuh |
| **工程兼容性** | Elastic tk-btf（老旧内核 KProbes + BTF） |
| **实战踩坑** | Joel Schumacher（路径解析、ABI、`__randomize_layout`） |
| **入门实践** | 本文（fanotify → eBPF → LSM 的演进路径） |

这篇文章是很好的**入门级实战指南**——如果你想从零开始构建 eBPF 文件监控，这篇文章和 Joel Schumacher 的文章应该是你的首选阅读材料，它们会让你提前了解将要面对的全部工程挑战。
