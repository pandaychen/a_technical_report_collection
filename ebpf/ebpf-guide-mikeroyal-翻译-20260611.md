# eBPF 指南（mikeroyal/eBPF-Guide）中文翻译

> 原文链接：[mikeroyal/eBPF-Guide](https://github.com/mikeroyal/eBPF-Guide)
> 原文标题：eBPF (extended Berkeley Packet Filter) Guide
> 作者：Mike Royal
> 翻译时间：2026 年 6 月 11 日
> 译者注：本文为 mikeroyal/eBPF-Guide 仓库 README 的中文翻译版。原仓库收录了围绕 eBPF 的工具、库、相关编译器/语言生态、网络/容器/数据库等周边知识。为忠于原文，结构与条目顺序保持一致；对于纯链接列表（如学习资源），保留英文条目并加上简短中文释义。

---

## 简介

一份覆盖 eBPF 应用、库以及工具的指南，帮助你成为更好、更高效的 eBPF 开发者。

> **提示**：你可以在 VSCode 中通过 `Markdown PDF` 扩展将该 Markdown 文件方便地转换为 PDF。

---

## 目录

1. eBPF 入门（Getting Started with eBPF）
   - eBPF 工具与库（eBPF Tools & Libraries）
   - 书籍与教程（Books & Tutorials）
2. LLVM 开发
3. Go 开发
4. C/C++ 开发
5. Rust 开发
6. 网络（Networking）
7. Kubernetes
8. 数据库（Databases）

---

## 一、eBPF 入门（Getting Started with eBPF）

### 相关 eBPF 公司

- **Isovalent**：由 Cilium 与 eBPF 的核心创建者们创立的公司，面向现代云原生基础设施提供网络、安全与可观测性的开源软件与企业级解决方案。

### 1.1 eBPF 工具与库

eBPF 是一项可以在 Linux 内核中运行沙箱程序的技术，它无需修改内核源码、也无需加载内核模块。通过让 Linux 内核可编程，基础设施类软件可以在已有层之上叠加更智能、更丰富的能力，而不必持续往系统中堆叠新的复杂层。

> **eBPF 架构总览（图源：eBPF.io）**

下面按原文顺序汇总各类 eBPF 项目与库的中文释义：

- **eBPF for Windows**：在 Windows 平台之上运行 eBPF 的实现。eBPF 以「为 OS 内核扩展能力（如 DoS 防护、可观测性）」而闻名，本项目将其能力带到 Windows。其上还有基于该实现的 **Cilium L4 Load Balancer using eBPF-for-Windows**。

> **eBPF for Windows 架构总览（图源：Microsoft）**

- **XDP（eXpress Data Path）**：允许开发者将 eBPF 程序挂载到 Linux 内核（4.8+）网络驱动实现的低层 hook，以及驱动后的通用 hook 上的技术；常用于 eBPF 架构中以内核旁路（kernel bypass）方式实现高性能数据包处理。

- **AF_XDP**：一种为高性能数据包处理优化的地址族（address family）。

- **BCC（BPF Compiler Collection）**：用于创建高效内核跟踪与操作程序的工具集，包含若干实用工具与示例。BCC 基于扩展 BPF（即 eBPF），该特性最早出现在 Linux 3.15，但 BCC 的多数能力需要 Linux 4.1 及以上。

> **BCC 性能工具集（图源：Brendan Gregg）**

- **bpftrace**：面向 Linux eBPF 的高级跟踪语言，语法借鉴 awk 与 C，以及 DTrace、SystemTap 等前辈跟踪器。bpftrace 使用 LLVM 作为后端，将脚本编译为 eBPF 字节码，并将 BCC 作为库与 Linux eBPF 子系统及现有跟踪能力/挂载点交互。

- **Cilium**：开源项目，提供基于 eBPF 的网络、安全与可观测性，从设计之初就面向 Kubernetes，旨在解决容器工作负载在可扩展性、安全与可视化方面的新需求。

- **Falco**：行为活动监控器，用于检测应用中的异常行为。Falco 借助 eBPF 在 Linux 内核层做审计，并辅以容器运行时指标、Kubernetes 指标等输入流，实现对容器、应用、主机与网络活动的持续监控与检测。

- **Katran**：Facebook 开源的 C++ 库 + eBPF 程序，用于构建高性能 4 层负载均衡转发面。Katran 利用内核 XDP 设施在内核内做快速包处理，性能随网卡接收队列数线性扩展，并使用 RSS 友好的封装方式将流量转发到 L7 LB。

- **Hubble**：构建在 Cilium 与 eBPF 之上的全分布式云原生网络/安全可观测性平台，可对服务通信、行为与底层网络基础设施提供完全透明的深度可视化。

- **Pixie**：面向 Kubernetes 应用的开源可观测性工具，可查看集群高层状态（服务图、集群资源、应用流量），也可下钻到细节视图（Pod 状态、火焰图、单条完整请求等）。

- **BumbleBee**：一个工具，帮助使用 OCI 镜像来构建、运行、分发 eBPF 程序；让你专注于编写 eBPF 代码，而由它处理用户态组件并自动将数据暴露为指标或日志。

- **Sysmon for Linux**：监控并记录系统活动（进程生命周期、网络连接、文件系统写入等）的工具。Sysmon 跨重启工作，使用高级过滤识别恶意活动以及攻击者/恶意软件在网络内的行为。

- **KubeArmor**：云原生运行时安全实施系统，在系统级别限制 Pod、容器、节点（VM）的进程执行、文件访问、网络等行为，底层利用 AppArmor、SELinux、BPF-LSM 等 Linux 安全模块（LSM）执行用户策略。

- **Caretta**：轻量级独立工具，可即时绘制 K8s 集群中服务的网络可视化拓扑；底层使用 eBPF 高效采集集群内所有服务网络交互，并用 Grafana 做查询与可视化。

- **dae**：基于 eBPF 的 Linux 高性能透明代理方案。

- **eunomia-bpf**：编译器与运行时框架，借助 JSON 与 WebAssembly OCI 镜像，帮助你更轻松地构建、分发、运行 CO-RE eBPF 程序。

- **Kindling**：基于 eBPF 的云原生监控工具，旨在帮助用户从内核到代码栈理解应用行为；通过 trace profiling 让用户秒级定位根因；同时提供 K8s 网络流量概览以及 TCP 重传、DNS、吞吐、TPS 等多种内置网络监控仪表盘。

- **Odigos**：无需修改代码的分布式追踪工具，使用 OpenTelemetry 与 eBPF 即时监控任意应用。

- **SSHLog**：用 C++/Python 编写的 Linux 守护进程，通过 eBPF 被动监控 OpenSSH 服务器；任意特性可启用/禁用/定制；与现有 OpenSSH 协同工作，无需替换 SSH 守护进程，安装即用。

- **L3AFD**：L3AF 控制面的核心组件——一个守护进程，用于编排与管理多个 eBPF 程序；它运行在每个需要执行 eBPF 程序的节点上，读取配置数据并管理 eBPF 程序的执行与监控。

- **Wachy**：为基于 eBPF 的用户态性能交互式调试提供 UI 的工具。

- **Merbridge**：使用 eBPF 加速 Service Mesh 的工具——「就像跨越爱因斯坦-罗森桥（虫洞）一般」。

- **DeepFlow**：面向云原生开发者的高自动化可观测性平台，结合 eBPF、WASM、OpenTelemetry 等新技术，创新地实现 AutoTracing、AutoMetrics、AutoTagging、SmartEncoding 等核心机制，极大避免代码侵入并显著降低后端数仓资源开销。

- **Parca**：面向 CPU 与内存的持续性能剖析（continuous profiling）工具，可下钻到行号并贯穿整个时间轴；用于降低基础设施成本、提升性能与可靠性。

- **loxilb**：基于 eBPF 内核的 K8s 外部 LoadBalancer 服务实现，赋能 Edge / 5G / IoT / XaaS 应用。

- **kube-loxilb**：loxilb 对 K8s service load-balancer spec 的实现，包含对 LoadBalancer Class、IPAM（共享或独占）等的支持。

- **loxi-ccm**：K8s LoadBalancer 规范的另一种实现，作为 cloud-provider 的一部分运行，并提供 LB 全生命周期管理。

- **loxicmd**：loxilb 的命令行工具，类似于 loxilb 的 `kubectl`。

- **Kubectl-trace**：kubectl 插件，可在 Kubernetes 集群中调度 `bpftrace(8)` 程序的执行；无需在集群上预装组件，指向集群即可调度临时 Job（trace-runner）执行 bpftrace。

- **Ply**：基于 eBPF 的 Linux 动态跟踪器，面向嵌入式系统设计，用 C 编写；运行只需 libc 与具备 eBPF 支持的现代 Linux 内核，**不依赖 LLVM**。脚本语法类 C，深受 awk(1) 与 dtrace(1) 启发。

- **Tracee**：面向 Linux 的运行时安全与取证工具，使用 eBPF 在运行时跟踪系统与应用，并对采集到的事件做行为模式分析以发现可疑行为。

- **bpfcov**：针对实际在 Linux 内核中运行的 eBPF 程序的源码级覆盖率工具。

- **eCapture**：使用 eBPF 在不需要 CA 证书的情况下抓取 SSL/TLS 明文内容的工具。

- **Tetragon**：基于 eBPF 的安全可观测性与运行时强制（Runtime Enforcement）。

- **SkyWalking**：面向云原生分布式系统的开源 APM 系统，覆盖监控、追踪与诊断能力。

- **Skydive**：开源实时网络拓扑与协议分析器，目标是帮助全面理解网络基础设施中正在发生的事情。

- **Linux Kernel**：Linux 内核包含运行 eBPF 程序所需的 eBPF 运行时；它实现了 `bpf(2)` 系统调用以与 Program、Map、BTF 等交互，并提供各类 eBPF 程序可挂载的 attach 点；内核中还含有 eBPF **校验器**（verifier）以确保程序安全，以及 **JIT 编译器** 将程序翻译为本地机器码。诸如 `bpftool`、`libbpf` 等用户态工具也作为内核上游的一部分维护。

- **Landlock LSM**：一个用于创建带作用域访问控制（沙箱）的 Linux 安全模块框架；设计上面向**非特权进程**可用，同时遵循其他访问控制机制（DAC、LSM 等）所执行的系统安全策略。

- **LLVM 编译器基础设施**：包含将类 C 语法翻译为 eBPF 指令所需的 eBPF 后端；LLVM 生成的 eBPF ELF 文件包含程序代码、map 描述、重定位信息以及 BTF 元数据——这些信息足以让 libbpf 等加载器准备并将程序加载进内核。

- **Gobpf**：Go 语言实现的库，提供 BCC 框架的 Go 绑定以及从 ELF 文件加载/使用 eBPF 程序的低层例程。

- **rbpf**：用 Rust 实现的 eBPF 虚拟机与 JIT 编译器。

- **Libbpfgo**：libbpf 的 Go 封装，支持 BPF CO-RE，目标是完整实现 libbpf API；底层通过 CGo 调用链接的 libbpf。

- **Libbpf**：作为 Linux 内核上游一部分维护的 C/C++ 库；提供 eBPF 加载器，负责处理 LLVM 生成的 eBPF ELF 文件并加载入内核。libbpf 在能力与成熟度上得到了大幅提升，弥补了相对 BCC 的多数缺口；并支持 BCC 缺失的关键特性（如全局变量、BPF skeleton）。

- **Libbpf-rs**：用 Rust 编写的、对 libbpf 的安全且地道的封装；与 libbpf-cargo（libbpf 的 cargo 插件）一起，可用于编写「一次编译、随处运行」（CO-RE）的 eBPF 程序。

- **Redbpf**：Rust 的 eBPF 工具链，包含与 BPF/eBPF 程序协作的一组 Rust 库。

- **redcanary-ebpf-sensor**：从 Linux 内核采集安全相关事件数据的一组 BPF 程序；这些 BPF 程序合并为单个 ELF 文件，可根据运行的操作系统与内核版本选择性地加载其中的 probe。

- **bpflock**：「锁定 Linux 主机」——一款基于 eBPF 的安全工具，用于锁定与审计 Linux 机器。

- **coroot-node-agent**：基于 eBPF 的 Prometheus exporter，采集容器粒度的全面指标：容器到容器 TCP 连接、网络延迟、CPU delay accounting、日志摘要、云实例元数据等。

- **Kernel-collector**：Netdata 出品的 Linux 内核 eBPF 采集器。

- **socket-connect-bpf**：BPF/eBPF 的 Linux 命令行工具，将每个发起新（网络）连接的应用以人类可读的形式打印到标准输出。

- **Polycube**：基于 eBPF/XDP 的软件框架，用于在 Linux 内核中运行快速网络服务（如桥、路由器、防火墙等）。Polycube 服务（称为 cube）可以拼接成任意服务链，为 namespace、容器、虚拟机和物理主机提供自定义网络连通性。

### 1.2 书籍与教程（Books & Tutorials）

- **BPF Performance Tools**（书籍）—— Brendan Gregg；同名 GitHub 仓库可参考。
- **Systems Performance: Enterprise and the Cloud, 2nd Edition (2020)** —— Brendan Gregg。
- **Security Observability with eBPF** —— Jed Salazar & Natalia Reka Ivanko。
- **What Is eBPF?** —— Liz Rice。
- **The Beginner's Guide to eBPF** —— Liz Rice。
- **eBPF - From a Programmer's Perspective** —— Niclas Hedam（PDF）。
- **Learn eBPF Tracing: Tutorial and Examples** —— Brendan Gregg。
- **eBPF Instruction Set** —— Linux 内核官方文档。
- **How We Used eBPF to Build Programmable Packet Filtering in Magic Firewall** —— Cloudflare。
- **eBPF assembly with LLVM** —— Quentin Monnet。

---

## 二、LLVM 开发

### 2.1 LLVM 学习资源

**LLVM** 是一个由模块化、可复用的编译器与工具链组件（汇编器、编译器、调试器等）构成的库；这些组件让 LLVM 既可作为编译器框架，也提供前端（解析器与词法分析器）和后端（将 LLVM 中间表示转换为机器码）。

**Clang** 是 LLVM 项目的 C 语言族（C、C++、Objective C/C++、OpenCL、CUDA、RenderScript）前端与工具基础设施。

主要参考链接：

- LLVM Project GitHub
- LLVM Documentation（LLVM 官方文档）
- LLVM Discussion Forum（LLVM 论坛）
- LLVM | Apple Developer Forums
- Contributing to LLVM（贡献指南）
- Getting Started with LLVM（入门指南）
- Getting Started with Clang（Clang 入门）
- How To Setup Clang Tooling For LLVM
- Using Clang-Tidy in Visual Studio
- Configure VS Code for Clang/LLVM on macOS

### 2.2 LLVM 工具、库与框架

- **Visual Studio Code**：面向现代 Web 与云应用构建/调试的代码编辑器。
- **Code Server**：可在任意机器上运行 VS Code 并通过浏览器访问的工具。
- **Clang-Format**：用于格式化 C/C++/Java/JavaScript/Objective-C/Objective-C++/Protobuf 代码的工具。
- **Clang-Tidy**：基于 Clang 的 C++ "linter"，提供可扩展的诊断/修复框架，覆盖编码风格、接口误用，以及静态分析可发现的潜在 Bug；模块化设计方便编写新检查项。
- **Clangd**：使用 clangd 为 VS Code 提供 C/C++ 语言 IDE 特性的扩展。
- **LLD**：LLVM 项目出品的链接器，可作为系统链接器的替代品，运行更快；支持 ELF（Unix）、PE/COFF（Windows）、Mach-O（macOS）以及 WebAssembly。
- **TinyGo**：基于 LLVM 的 Go 编译器，用于微控制器、WebAssembly（Wasm）以及命令行工具等小型场景。
- **FileCheck**：灵活的模式匹配文件校验工具。
- **tblgen**：从 description 生成 C++ 代码。
- **clang-tblgen**：从 description 生成 Clang 用的 C++ 代码。
- **lldb-tblgen**：从 description 生成 LLDB 用的 C++ 代码。
- **llvm-tblgen**：从 target description 生成 LLVM 用的 C++ 代码。
- **mlir-tblgen**：从 description 生成 MLIR 用的 C++ 代码。
- **lit**：LLVM 集成测试工具（Integrated Tester）。
- **llvm-exegesis**：LLVM 机器指令基准测试工具。
- **llvm-locstats**：DWARF 调试位置统计工具。
- **llvm-pdbutil**：PDB 文件取证与诊断工具。
- **llvm-profgen**：LLVM SPGO 性能数据生成工具。
- **bugpoint**：自动化测试用例缩减工具。
- **llvm-extract**：从 LLVM module 中提取函数。
- **llvm-bcanalyzer**：LLVM 位码分析器。
- **llvm-addr2line**：可作为 `addr2line` 的替代。
- **llvm-ar**：LLVM 归档器。
- **llvm-cxxfilt**：LLVM 符号 demangler。
- **llvm-install-name-tool**：操作 install-name 与 rpath 的 LLVM 工具。
- **llvm-nm**：列出 LLVM 位码与目标文件的符号表。
- **llvm-objcopy**：目标文件复制与编辑工具。
- **llvm-objdump**：LLVM 的目标文件 dump 工具。
- **llvm-ranlib**：生成归档索引。
- **llvm-readelf**：GNU 风格的 LLVM 目标文件读取器。
- **llvm-size**：打印目标文件大小信息。
- **llvm-strings**：打印目标文件中的字符串。
- **llvm-strip**：目标文件 strip 工具。

---

## 三、Go 开发

### 3.1 Go 学习资源

**Go** 是一门开源编程语言，旨在让开发者轻松构建简洁、可靠、高效的软件。

主要参考链接：

- Golang Contribution Guide（Golang 贡献指南）
- Google Developers Training
- Google Developers Certification
- Uber's Go Style Guide（Uber Go 编码规范）
- GitLab's Go standards and style guidelines
- Effective Go
- Go: The Complete Developer's Guide (Golang)（Udemy）
- Getting Started with Go（Coursera）
- Programming with Google Go（Coursera）
- Learning Go Fundamentals（Pluralsight）
- Learning Go（Codecademy）

### 3.2 Go 工具与框架

- **golang/tools**：保存 Go 语言相关各类包与工具源码的官方仓库。
- **Go in Visual Studio Code**：VS Code 的 Go 扩展，提供 IntelliSense、代码导航、符号搜索、括号匹配、片段等开发特性。
- **Traefik**：现代 HTTP 反向代理与负载均衡器，便于部署微服务，可与 Docker、Swarm、Kubernetes、Marathon、Consul、Etcd、Rancher、Amazon ECS 等组合并自动配置。
- **Gitea**：一杯茶时间就能跑起来的自托管 Git 服务，用 Go 编写，可在 Linux、macOS、Windows，以及 x86、amd64、ARM、PowerPC 架构上独立分发二进制运行。
- **OpenFaaS**：让无服务器函数变得简单——便于将事件驱动的函数与微服务部署到 Kubernetes，无需重复样板代码；可将代码或现有二进制打包为 Docker 镜像，获得自动伸缩与指标。
- **micro**：基于终端的文本编辑器，目标是易用且直观，同时充分利用现代终端能力；定位为 nano 的「精神继承者」。
- **Gravitational Teleport**：现代化的安全网关，用于通过 SSH 或浏览器中的 SSH-over-HTTPS 远程访问 Linux 服务器集群或 Kubernetes 集群。
- **NATS**：简单、安全、高性能的数字系统/服务/设备通信系统；CNCF 项目；30+ 客户端语言实现，可在本地、云端、边缘乃至树莓派上运行。
- **Act**：让你在本地运行 GitHub Actions 的 Go 程序。
- **Fiber**：基于 Fasthttp（Go 中最快的 HTTP 引擎）构建、灵感来自 Express 的 Web 框架；面向快速开发与零分配性能。
- **Glide**：Golang 的 vendor 包管理器。
- **BadgerDB**：纯 Go 编写的可嵌入、持久化、快速 KV 数据库，是 Dgraph（分布式图数据库）的底层数据库；定位是 RocksDB 等非 Go 系 KV 存储的替代。
- **Go kit**：用于在 Go 中构建微服务（或优雅单体）的编程工具集，解决分布式系统与应用架构中的常见问题，让你专注业务价值。
- **Codis**：用 Go 编写的、基于代理的高性能 Redis 集群方案。
- **zap**：Go 中极快的结构化、分级日志库。
- **HttpRouter**：轻量级、高性能的 Go HTTP 路由器（多路复用器）。
- **Gorilla WebSocket**：Go 实现的 WebSocket 协议库。
- **Delve**：Go 调试器。
- **GORM**：Go 的优秀 ORM 库，对开发者友好。
- **Go Patterns**：Go 语言地道的设计模式与应用模式精选集。

---

## 四、C/C++ 开发

### 4.1 C/C++ 学习资源

**C++** 是一门跨平台语言，由 Bjarne Stroustrup 作为 C 的扩展提出，常用于构建高性能应用。

**C** 是一门通用的高级语言，最初由 Dennis M. Ritchie 在贝尔实验室开发用于实现 UNIX 操作系统；它支持结构化编程、词法变量作用域与递归，具备静态类型系统，并提供能高效映射到典型机器指令的语言构造，因而是当今使用最广的编程语言之一。

**Embedded C** 是 C 标准委员会为弥合不同嵌入式系统中 C 扩展之间差异而发布的一组语言扩展，用以增强诸如定点算术、多个独立内存区、基本 I/O 等微处理器特性，是世界上最常用的嵌入式软件语言。

主要参考链接：

- C & C++ Developer Tools from JetBrains
- Open source C++ libraries on cppreference.com
- C++ Graphics libraries
- C++ Libraries in MATLAB
- C++ Tools and Libraries Articles
- Google C++ Style Guide
- Introduction C++ Education course on Google Developers
- C++ style guide for Fuchsia
- C and C++ Coding Style Guide by OpenTitan
- Chromium C++ Style Guide
- C++ Core Guidelines
- C++ Style Guide for ROS
- Learn C++
- Learn C: An Interactive C Tutorial
- C++ Institute
- C++ Online Training Courses on LinkedIn Learning
- C++ Tutorials on W3Schools
- Learn C Programming Online Courses on edX
- Learn C++ with Online Courses on edX
- Learn C++ on Codecademy
- Coding for Everyone: C and C++ course on Coursera
- C++ For C Programmers on Coursera
- Top C Courses on Coursera
- C++ Online Courses on Udemy
- Top C Courses on Udemy
- Basics of Embedded C Programming for Beginners on Udemy
- C++ For Programmers Course on Udacity
- C++ Fundamentals Course on Pluralsight
- Introduction to C++ on MIT Free Online Course Materials
- Introduction to C++ for Programmers | Harvard
- Online C Courses | Harvard University

### 4.2 C/C++ 工具与框架

- **AWS SDK for C++**：AWS C++ SDK。
- **Azure SDK for C++ / Azure SDK for C**：Azure 的 C++/C SDK。
- **C++ Client Libraries for Google Cloud Services**：Google Cloud 的 C++ 客户端库。
- **Visual Studio**：来自 Microsoft 的功能丰富的 IDE，可用于软件开发的方方面面（编辑、调试、构建、发布），支持 Windows API、Windows Forms、WPF、Windows Store 等开发平台。
- **Visual Studio Code**：现代 Web 与云应用的代码编辑器。
- **Vcpkg**：跨 Windows、Linux、MacOS 的 C++ 库管理器。
- **ReSharper C++**：JetBrains 出品的 Visual Studio C++ 扩展。
- **AppCode**：JetBrains 出品的 IDE，持续监控代码质量，支持 Objective-C、Swift、C/C++ 等的代码检查与快速修复。
- **CLion**：JetBrains 出品的跨平台 C/C++ IDE。
- **Code::Blocks**：免费的 C/C++/Fortran IDE，可基于插件框架进行扩展与配置。
- **CppSharp**：让 C/C++ 代码可被 .NET 生态使用的工具与库；解析 C/C++ 头文件与库，生成桥接代码。
- **Conan**：现代 C++ 的开源包管理器与依赖管理。
- **High Performance Computing (HPC) SDK**：NVIDIA 平台上加速 HPC 仿真应用所需的 C/C++/Fortran 编译器、库与分析工具集。
- **Thrust**：类似 C++ 标准库的并行编程库，提升程序员生产力，并在 GPU 与多核 CPU 间提供性能可移植性；与 CUDA、TBB、OpenMP 互操作。
- **Boost**：聚焦前沿 C++ 的教育性社区项目；自 2007 年起每年参与 Google Summer of Code。
- **Automake**：自动生成符合 GNU 编码规范的 `Makefile.in`；依赖 GNU Autoconf。
- **CMake**：开源、跨平台的构建/测试/打包工具集，使用与平台/编译器无关的配置文件控制软件编译，并生成 native makefile 与 IDE 工程。
- **GDB**：调试器，让你看到另一个程序运行时（或崩溃瞬间）正在发生什么。
- **GCC**：GNU 编译器集合，包含 C、C++、Objective-C、Fortran、Ada、Go、D 的前端与对应库。
- **GSL**：GNU 科学计算库，C/C++ 数值库；提供随机数生成器、特殊函数、最小二乘拟合等 1000+ 函数及完整测试套件。
- **GLEW（OpenGL Extension Wrangler）**：跨平台的 OpenGL 扩展加载库，用于运行时检测目标平台支持的 OpenGL 扩展。
- **Libtool**：通用库支持脚本，将共享库使用细节隐藏在一致、可移植的接口之后。
- **Maven**：基于 POM（Project Object Model）的软件项目管理与理解工具，集中管理构建、报告与文档。
- **TAU（Tuning And Analysis Utilities）**：通过函数、方法、基本块、语句插桩以及事件采样收集性能信息；支持模板、命名空间等所有 C++ 特性。
- **Clang**：生产级的 C/Objective-C/C++/Objective-C++ 编译器，针对 X86-32/64 与 ARM 优化；被用于构建 Chrome、Firefox 等性能关键软件。
- **OpenCV**：聚焦实时应用的高度优化库，提供 C++/Python/Java 跨平台接口，覆盖 Linux、MacOS、Windows、iOS、Android。
- **Libcu++**：NVIDIA 的 C++ 标准库异构实现，可在 CPU 与 GPU 代码间互通。
- **ANTLR**（ANother Tool for Language Recognition）：强大的解析器生成器，适用于读取/处理/执行/翻译结构化文本或二进制文件，被广泛用于构建语言、工具与框架。
- **Oat++**：轻量、强大的 C++ Web 框架，零依赖、易移植，面向高扩展、低资源占用的 Web 应用。
- **JavaCPP**：在 Java 中高效访问 native C++ 的程序，类似某些 C/C++ 编译器与汇编语言交互的方式。
- **Cython**：让为 Python 写 C 扩展像写 Python 一样简单的语言；基于 Pyrex，并支持调用 C 函数、为变量与类属性声明 C 类型等更激进的优化。
- **Spdlog**：极快、header-only/可编译的 C++ 日志库。
- **Infer**：用 OCaml 编写、覆盖 Java/C++/Objective-C/C 的静态分析工具。

---

## 五、Rust 开发

### 5.1 Rust 学习资源

**Rust** 是一门聚焦性能与安全的多范式编程语言。Rust 的运行时开销与 C/C++ 相当，标准库被划分为 `core` 与 `std`：`core` 仅含最底层方面，不含分配、线程等高层特性，因此适合做 OS 开发。

主要参考链接：

- The Rust Language Reference（语言参考）
- The Rust Programming Language Book（官方书）
- Learning Rust
- Why AWS loves Rust
- Rust Programming courses on Udemy
- Safety in Systems Programming with Rust（Stanford / Ryan Eberhardt）
- WebAssembly meets Kubernetes with Krustlet using Rust
- Microsoft's Project Verona

### 5.2 Rust 工具与框架

- **Cargo**：Rust 的包管理器，下载依赖并编译项目。
- **Crater**：在 Rust 生态局部跑实验的工具，主要用于检测 Rust 编译器的回归（构建大量 crate、运行其测试套件，并比较两个 Rust 版本的结果）；可本地（仅需 Docker）或云上分布式运行。
- **VSCode-Rust**：为 VS Code 添加 Rust 支持的插件，由 RLS 或 rust-analyzer 提供能力，由 Rust IDE/Editor 团队维护。
- **Apache Arrow**：内存分析的开发平台，提供让大数据系统快速处理和移动数据的技术；提供 C、C++、C#、Go、Java、JS、MATLAB、Python、R、Ruby、Rust 等库。
- **Wasmer**：基于 WebAssembly 的超轻量容器，可运行于桌面、云端、IoT，并嵌入到任意编程语言中。
- **Firecracker**：开源虚拟化技术，专为安全多租户的容器/函数服务而设计，使用 microVM 兼具 HW 虚拟化的安全/隔离与容器的速度/灵活；已被集成到 Kata Containers、Weaveworks Ignite 等容器运行时中。
- **Tokio**：Rust 的事件驱动、非阻塞 I/O 平台，用于编写异步应用。
- **TiKV**：开源分布式事务 KV 数据库，提供经典 KV API 以及 ACID 事务 API。
- **Sonic**：快速、轻量、无 schema 的搜索后端，在某些场景类似 Elasticsearch。
- **Hyper**：Rust 的快速且正确的 HTTP 库。
- **Rocket**：聚焦易用性、安全、可扩展与性能的 Rust 异步 Web 框架。
- **Clippy**：捕获常见错误、改进 Rust 代码的 lint 集合。
- **Servo**：Rust 编写的实验性 Web 浏览器引擎。
- **Vector**：高性能的端到端（agent + aggregator）可观测性数据平台，让用户掌控自己的可观测性数据。
- **RustPython**：用 Rust 实现的 Python 解释器。
- **Miri**：Rust 中级 IR 的解释器，可执行 cargo 项目的二进制与测试套件并检测某些未定义行为；还能在执行结束时报告内存泄漏。
- **Chalk**：用 Prolog 风格的逻辑求解器实现并定义 Rust 的 trait 系统。
- **stdarch**：Rust 标准库的厂商相关 API 与运行时特性检测。
- **Simpleinfra**：Rust 基础设施团队管理服务的工具与自动化集合（部分需要团队成员权限才能使用）。
- **Rustlings**：让你熟悉读写 Rust 代码的小练习集。
- **Krustlet**：用 Rust 实现的 Kubernetes Kubelet，监听调度器分配给它（基于特定 K8s tolerations）的新 Pod；当前为实验性。

### 5.3 基于 Rust 的操作系统

- **Redox**：Rust 编写的类 Unix 操作系统，把 Rust 的创新带进现代微内核与完整应用集合；由 Jeremy Soeller 持续开发。
- **Bottlerocket OS**：开源、基于 Linux 的容器宿主操作系统，聚焦安全性与可维护性，为容器工作负载提供可靠、一致、安全的平台。
- **Tock**：嵌入式操作系统，面向 Cortex-M 与 RISC-V 嵌入式平台，可同时运行多个互不信任的应用；通过 Rust 编写内核与驱动获得编译期内存安全/类型安全/严格别名保证，并使用 MPU 隔离应用。
- **Rust on Chrome OS**：在 Chrome OS / Chrome OS SDK 中创建 Rust 项目的官方说明文档。
- **Writing an OS in Rust**：Philipp Oppermann 的博客系列，使用 Rust 一步步构建一个小型操作系统。

---

## 六、网络（Networking）

### 6.1 网络学习资源

主要参考链接（认证与课程）：

- AWS Certified Security - Specialty Certification
- Microsoft Certified: Azure Security Engineer Associate
- Google Cloud Certified Professional Cloud Security Engineer
- Cisco Security Certifications
- The Red Hat Certified Specialist in Security: Linux
- Linux Professional Institute LPIC-3 Enterprise Security Certification
- Cybersecurity Training and Courses from IBM Skills
- Cybersecurity Courses and Certifications by Offensive Security
- Citrix Certified Associate – Networking (CCA-N)
- Citrix Certified Professional – Virtualization (CCP-V)
- CCNP Routing and Switching
- Certified Information Security Manager (CISM)
- Wireshark Certified Network Analyst (WCNA)
- Juniper Networks Certification Program Enterprise (JNCP)
- Networking courses and specializations from Coursera
- Network & Security Courses from Udemy
- Network & Security Courses from edX

### 6.2 网络工具与概念

- **Qt Network Authorization**：为 Qt 应用提供一组 API，使其能在不暴露用户密码的情况下，为在线账号与 HTTP 服务获取有限访问权限。
- **cURL**：提供库与命令行工具，用于通过 HTTP/HTTPS/FTP/FTPS/SCP/SFTP/TFTP/DICT/TELNET/LDAP/LDAPS/MQTT/POP3/POP3S/RTMP/RTMPS/RTSP/SMB/SMBS/SMTP/SMTPS 等协议传输数据；被广泛用于汽车、电视、路由器、打印机、手机、机顶盒等数十亿级安装场景。
- **cURL Fuzzer**：curl 项目的质量保证模糊测试工具。
- **DoH**：独立的 DNS-over-HTTPS 解析与查询应用。
- **Authelia**：开源高可用认证服务器，为运行在 NGINX 后的应用提供 SSO 与双因素认证。
- **nginx (engine x)**：HTTP/反向代理服务器、邮件代理服务器以及通用 TCP/UDP 代理服务器。
- **Proxmox Virtual Environment (VE)**：完整开源的企业虚拟化平台，内置 Web 界面，可管理 VM/容器、软件定义存储与网络、高可用集群等。
- **Wireshark**：流行的网络协议分析器，常用于网络排障、分析与协议开发。
- **HTTPie**：命令行 HTTP 客户端，目标是让 CLI 与 Web 服务交互尽可能「人类友好」。
- **HTTPStat**：以简洁布局可视化 curl 统计信息的工具。
- **Wuzz**：交互式 CLI HTTP 检查工具，可配合浏览器「Copy as cURL」功能检查/修改请求。
- **Websocat**：WebSocket 的命令行客户端，类似 netcat/curl 之于 `ws://`，并具备 socat 风格的高级功能。

**基础网络概念：**

- **连接（Connection）**：网络中传输的相关信息片段。通常意味着在数据传输前按协议建立连接，传输结束后拆除。
- **数据包（Packet）**：网络上传输的最基本单位。数据被拆分成包，像信封一样从一端送到另一端。包头包含源/目的地址、时间戳、网络跳数等信息；包体（payload）承载实际数据。
- **网络接口（Network Interface）**：任何访问网络硬件的软件接口。例如，若计算机有两块网卡，可分别配置其关联的网络接口。接口可对应物理设备，也可对应虚拟接口（如 loopback 本地回环）。
- **LAN（Local Area Network，局域网）**：不向公众互联网开放的本地网络，如家庭或办公室网络。
- **WAN（Wide Area Network，广域网）**：比 LAN 大得多的网络，通常指互联网整体。若接口连接到 WAN，一般意味着可通过互联网访问。
- **协议（Protocol）**：设备通信所遵循的规则与标准集合。低层协议包括 TCP、UDP、IP、ICMP；应用层协议包括 HTTP、SSH、TLS/SSL、FTP 等。
- **端口（Port）**：单台机器上可与特定软件绑定的地址，使服务器可通过多个应用同时通信。
- **防火墙（Firewall）**：决定进出服务器流量是否允许的程序，通常基于端口与流量类型创建规则。
- **NAT（Network Address Translation，网络地址转换）**：将进入路由服务器的请求翻译并转发到 LAN 内已知设备/服务器的技术，常见于物理 LAN 中通过单一公网 IP 路由到后端服务器。
- **VPN（Virtual Private Network，虚拟专用网）**：通过互联网连接多个 LAN 同时保持隐私，常用于让远程系统像处于本地网络一样访问，多用于安全场景。

### 6.3 网络分层

网络实现通常是**纵向分层**的：更高层对原始数据做更多抽象，让应用与用户更易使用，也让你能复用底层协议而不必重新发明轮子。

数据从一台机器发出时，从协议栈顶部向下过滤；在最低层完成到另一台机器的实际传输；到达对端后再自下而上穿越各层。每一层都可以为相邻层传来的数据添加自己的「包装」，供后续层决定如何处理。

**OSI 模型**（Open Systems Interconnect）定义了 7 层：

| 层级 | 名称 | 职责 |
|------|------|------|
| 7 | 应用层（Application） | 用户与应用最常交互的层；讨论资源可用性、通信伙伴、数据同步等 |
| 6 | 表示层（Presentation） | 映射资源、创建上下文；将低层网络数据翻译为应用期望的数据 |
| 5 | 会话层（Session） | 连接处理器；以持久方式创建、维护、销毁节点间连接 |
| 4 | 传输层（Transport） | 为上层提供可靠连接；可重传丢失/损坏数据并确认接收 |
| 3 | 网络层（Network） | 在不同节点间路由数据；使用地址决定发往哪台计算机；可将大消息分片并在对端重组 |
| 2 | 数据 Link 层 | 在现有物理连接上建立并维护节点间可靠链路 |
| 1 | 物理层（Physical） | 处理实际物理设备与连接管理（如以太网） |

**TCP/IP 模型**（Internet Protocol Suite）更简洁、应用更广，定义 4 层（部分与 OSI 重叠）：

| 层级 | 名称 | 职责 |
|------|------|------|
| 4 | 应用层（Application） | 在应用间创建并传输用户数据；远程应用对终端用户应像本地一样 |
| 3 | 传输层（Transport） | 进程间通信；使用端口寻址不同服务；可构建可靠或不可靠连接 |
| 2 | 互联网层（Internet） | 在节点间传输数据；知道连接端点但不关心具体路径；IP 地址在此层定义 |
| 1 | 链路层（Link） | 实现本地网络拓扑，使互联网层呈现可寻址接口；在相邻节点间建立连接并发送数据 |

**接口（Interfaces）**：计算机的网络通信端点。每个接口关联一个物理或虚拟网络设备。服务器通常为每块以太网卡或无线网卡配置一个可配置接口，并定义名为 `lo` 的 loopback（localhost）虚拟接口，用于本机进程间通信。

### 6.4 网络协议

网络通信通过多层协议「套娃」实现，一条数据可被多个协议逐层封装。

- **MAC（Media Access Control，媒体访问控制）**：链路层协议，用于区分具体设备。每台设备在制造时应获得唯一 MAC 地址。通过 MAC 寻址硬件，即使上层软件在运行中更改设备名，也能用唯一值引用设备。MAC 是链路层中你最常接触的协议之一。

- **IP 协议**：互联网工作的基础协议之一。IP 地址在网络内唯一，使机器能跨网络寻址。在 TCP/IP 模型中位于互联网层。网络可互联，但跨网边界需路由。IP 假设网络不可靠且存在多条可达路径，可动态切换。最常见实现是 IPv4，IPv6 因地址稀缺与能力增强而逐渐普及。

- **ICMP（Internet Control Message Protocol，互联网控制报文协议）**：在设备间发送可用性或错误状态消息，被 `ping`、`traceroute` 等诊断工具使用。通常在其他类型数据包遇到问题时发送 ICMP 包，作为网络通信的反馈机制。

- **TCP（Transmission Control Protocol，传输控制协议）**：位于 TCP/IP 传输层，用于建立可靠连接。TCP 将数据封装为包，通过下层方法传到对端，对端可检查错误、请求重传并重组为逻辑整体交给应用层。TCP 在传输前通过**三次握手**建立连接，传输后通过**四次挥手**拆除。WWW、FTP、SSH、Email 等大量互联网应用依赖 TCP。

- **UDP（User Datagram Protocol，用户数据报协议）**：TCP 在传输层的常见搭档，提供**不可靠**传输——不验证对端是否收到。对某些场景是缺点，但对另一些场景至关重要：无需等待确认与重传，UDP 比 TCP 更快；不建立连接，直接发送数据。适合查询网络资源等简单事务；不维护状态，适合一对多实时客户端，因此常用于 VoIP、游戏等不能容忍延迟的应用。

- **HTTP（Hypertext Transfer Protocol，超文本传输协议）**：应用层协议，是 Web 通信的基础。`GET`、`POST`、`DELETE` 等动词以不同方式操作请求数据。

- **FTP（File Transfer Protocol，文件传输协议）**：应用层协议，用于在主机间传输完整文件；天生不安全，除非作为只读公共资源，否则不建议暴露在公网。

- **DNS（Domain Name System，域名系统）**：应用层协议，为互联网资源提供人类友好的命名机制，将域名解析为 IP 地址，使浏览器可通过名称访问站点。

- **SSH（Secure Shell，安全外壳协议）**：应用层加密协议，用于安全地与远程服务器通信；因其端到端加密与普及性，许多技术围绕 SSH 构建。

- **REST（REpresentational State Transfer）**：一种架构风格，为 Web 上计算机系统之间的交互提供标准，使系统更易互操作。

- **JWT（JSON Web Token）**：紧凑、URL 安全的声明表示方式，可在双方之间传递；声明以 JSON 对象编码，并使用 JWS 数字签名。

- **OAuth 2.0**：开源授权框架，使应用能在 HTTP 服务（如 Amazon、Google、Facebook、Microsoft、Twitter、GitHub、DigitalOcean 等）上获取对用户账号的有限访问；将用户认证委托给托管账号的服务，并授权第三方应用访问该账号。

---

## 七、Kubernetes

### 7.1 Kubernetes 学习资源

**Kubernetes（K8s）** 是一个开源系统，用于自动化部署、扩缩和管理容器化应用。

主要参考链接：

- Getting Kubernetes Certifications（K8s 认证）
- Getting started with Kubernetes on AWS
- Kubernetes on Microsoft Azure
- Intro to Azure Kubernetes Service
- Azure Red Hat OpenShift
- Getting started with Google Cloud
- Getting started with Kubernetes on Red Hat
- Getting started with Kubernetes on IBM
- Red Hat OpenShift on IBM Cloud
- Enable OpenShift Virtualization on Red Hat OpenShift
- YAML basics in Kubernetes
- Elastic Cloud on Kubernetes
- Docker and Kubernetes
- Running Apache Spark on Kubernetes
- Kubernetes Across VMware vRealize Automation
- VMware Tanzu Kubernetes Grid
- All the Ways VMware Tanzu Works with AWS
- VMware Tanzu Education
- Using Ansible in a Cloud-Native Kubernetes Environment
- Managing Kubernetes (K8s) objects with Ansible
- Setting up a Kubernetes cluster using Vagrant and Ansible
- Running MongoDB with Kubernetes
- Kubernetes Fluentd
- Understanding the new GitLab Kubernetes Agent
- Intro Local Process with Kubernetes for Visual Studio 2019
- Kubernetes Contributors
- KubeAcademy from VMware
- Kubernetes Tutorials from Pulumi
- Kubernetes Playground by Katacoda
- Scalable Microservices with Kubernetes course from Udacity

### 7.2 Kubernetes 工具、框架与项目

- **Open Container Initiative (OCI)**：为创建开放的容器格式与运行时行业标准而设立的开源治理结构。
- **Buildah**：用于构建 OCI 镜像的命令行工具，可与 Docker、Podman、Kubernetes 配合使用。
- **Podman**：无守护进程、开源、Linux 原生的容器工具，便于查找、运行、构建、分享与部署 OCI 容器与镜像；CLI 对 Docker 用户友好。
- **Containerd**：管理主机系统完整容器生命周期的守护进程，覆盖镜像传输/存储、容器执行/监督、底层存储、网络挂载等；支持 Linux 与 Windows。
- **Google Kubernetes Engine (GKE)**：托管的、生产就绪的容器化应用运行环境。
- **Azure Kubernetes Service (AKS)**：无服务器 Kubernetes，集成 CI/CD 体验，具备企业级安全与治理。
- **Amazon EKS**：在多个可用区运行 Kubernetes 控制平面实例以确保高可用。
- **AWS Controllers for Kubernetes (ACK)**：让你直接从 Kubernetes 管理 AWS 服务，便于构建可扩展、高可用的 K8s 应用。
- **Container Engine for Kubernetes (OKE)**：Oracle 托管的容器编排服务，Oracle Cloud Infrastructure 将其作为免费服务提供。
- **Anthos**：现代应用管理平台，为云端与本地环境提供一致的开发与运维体验。
- **Red Hat OpenShift**：全托管 Kubernetes 平台，为本地、混合云与多云部署提供基础。
- **OKD**：面向持续应用开发与多租户部署优化的 Kubernetes 社区发行版，在 K8s 之上增加面向开发与运维的工具。
- **Odo**：面向在 Kubernetes/OpenShift 上编写、构建、部署应用的快速、迭代、简洁 CLI 工具。
- **Kata Operator**：在 OpenShift 与 Kubernetes 集群上管理 Kata Runtime 生命周期（安装/升级/卸载）的 Operator。
- **Thanos**：可组合为高可用、无限存储容量指标系统的组件集，可无缝叠加在现有 Prometheus 部署之上。
- **OpenShift Hive**：运行在 Kubernetes/OpenShift 之上的 Operator 服务，用于配置并初始化 OpenShift 4 集群。
- **Rook**：将分布式存储系统转化为自管理、自扩展、自修复存储服务的工具，自动化存储管理员的部署、引导、配置、供给、扩缩、升级、迁移、灾备、监控与资源管理任务。
- **VMware Tanzu**：集中管理平台，用于在多个团队与私有/公有云之间一致地运营与保护 Kubernetes 基础设施与现代应用。
- **Kubespray**：结合 Kubernetes 与 Ansible，可在 AWS、GCE、Azure、OpenStack、vSphere、Packet（裸金属）、OCI（实验性）或裸金属上轻松安装 K8s 集群。
- **KubeInit**：提供多种 Kubernetes 发行版部署与配置的 Ansible playbook 与 role。
- **Rancher**：面向采用容器的团队的完整软件栈，解决多 K8s 集群的运营与安全挑战，并为 DevOps 提供运行容器化工作负载的集成工具。
- **K3s**：高可用、通过认证的 Kubernetes 发行版，面向无人值守、资源受限、远程位置或 IoT 设备内的生产工作负载。
- **Helm**：Kubernetes 包管理器，便于安装与管理 K8s 应用。
- **Knative**：基于 Kubernetes 的平台，用于构建、部署与管理现代无服务器工作负载；处理网络、自动扩缩（甚至缩容到零）、版本跟踪等运维细节。
- **KubeFlow**：致力于让在 Kubernetes 上部署 ML 工作流变得简单、可移植、可扩展。
- **Kubebox**：Kubernetes 的终端与 Web 控制台。
- **Kubsec**：Kubernetes 资源的安全风险分析工具。
- **Replex**：面向云原生企业的 Kubernetes 治理与成本管理。
- **Virtual Kubelet**：伪装成 kubelet 的开源 Kubernetes kubelet 实现。
- **Telepresence**：面向 Kubernetes 与 OpenShift 微服务的快速本地开发工具。
- **Weave Scope**：自动检测进程、容器、主机；无需内核模块、agent、特殊库或编码；与 Docker、Kubernetes、DCOS、AWS ECS 无缝集成。
- **Nuclio**：高性能「无服务器」框架，聚焦数据、I/O 与计算密集型工作负载；与 Jupyter、Kubeflow 等数据科学工具深度集成。
- **Supergiant Control**：管理基础设施上集群生命周期并通过 HELM 部署应用，帮助更快上手 Kubernetes。
- **Supergiant Capacity (Beta)**：确保 K8s 集群在任意时刻都有满足资源负载的硬件，防止过度配置与超支。
- **Test suite for Kubernetes**：包含两个 Helm chart 的测试套件，用于网络带宽测试与负载测试。
- **Keel**：自动化 Helm、DaemonSet、StatefulSet、Deployment 更新的 Kubernetes Operator。
- **Kube Monkey**：Netflix Chaos Monkey 的 Kubernetes 实现，随机删除 Pod 以验证服务的故障恢复能力。
- **Kube State Metrics (KSM)**：监听 K8s API Server 并生成对象状态指标的服务，关注 Deployment、Node、Pod 等对象健康而非 K8s 组件本身。
- **Sonobuoy**：诊断工具，以可访问、非破坏性的方式运行配置测试，帮助理解集群状态。
- **PowerfulSeal**：强大的 K8s 集群测试工具，尽早发现问题。
- **Test Infra**：Kubernetes 项目测试与自动化需求的工具与配置文件仓库。
- **cAdvisor (Container Advisor)**：为容器用户提供运行中容器资源使用与性能特征洞察的守护进程，收集资源隔离参数、历史使用、直方图与网络统计等。
- **Etcd**：分布式 KV 存储，为分布式系统或机器集群提供可靠的数据存储方式；Kubernetes 将其用作服务发现后端并存储集群状态与配置。
- **OpenEBS**：基于 Kubernetes 的容器附加存储（CAS）工具，用于创建有状态应用。
- **Container Storage Interface (CSI)**：让 Kubernetes 等容器编排平台通过插件与存储数据无缝通信的 API。
- **MicroK8s**：提供完整 Kubernetes 体验的工具，全容器化部署并支持压缩的空中更新，支持 Linux、Windows、MacOS。
- **Charmed Kubernetes**：Canonical 开发的、面向多云环境优化的一体化、开箱即用、合规的 Kubernetes 平台。
- **Grafana Kubernetes App**：监控 K8s 集群性能的应用，包含 Cluster、Node、Pod/Container、Deployment 四个仪表盘，可自动部署所需 Prometheus exporter 与默认 scrape 配置。
- **KubeEdge**：将原生容器化应用编排能力扩展到边缘主机的开源系统，基于 Kubernetes 提供云边之间的网络、应用部署与元数据同步基础设施。
- **Lens**：面向日常处理 K8s 集群人员的最强 IDE，支持 MacOS、Windows、Linux。
- **kind**：使用 Docker 容器作为「节点」运行本地 K8s 集群的工具，最初为测试 Kubernetes 本身设计，也可用于本地开发或 CI。
- **Flux CD**：自动确保 K8s 集群状态与 Git 中配置一致的工具，使用集群内 Operator 触发部署，无需单独的 CD 工具。

---

## 八、数据库（Databases）

### 8.1 SQL/NoSQL 学习资源

**SQL** 是用于在关系型数据库中存储、操作与检索数据的标准语言。

**NoSQL** 数据库也常被称为「非关系型」或「非 SQL」数据库，强调其能以不同于关系型（基于行/表）数据库的方式处理海量、快速变化、非结构化数据。

**Transact-SQL (T-SQL)** 是 Microsoft 对 SQL 的扩展，所有工具与应用通过发送 T-SQL 命令与 SQL 数据库通信。

主要参考链接：

- Introduction to Transact-SQL
- SQL Tutorial by W3Schools
- Learn SQL Skills Online from Coursera
- SQL Courses Online from Udemy
- SQL Online Training Courses from LinkedIn Learning
- Learn SQL For Free from Codecademy
- GitLab's SQL Style Guide
- OracleDB SQL Style Guide Basics
- Tableau CRM: BI Software and Tools
- Databases on AWS
- Best Practices and Recommendations for SQL Server Clustering in AWS EC2
- Connecting from Google Kubernetes Engine to a Cloud SQL instance
- Educational Microsoft Azure SQL resources
- MySQL Certifications
- SQL vs. NoSQL Databases: What's the Difference?
- What is NoSQL?

### 8.2 SQL/NoSQL 工具与数据库

- **Netdata**：高保真基础设施监控与排障工具，Agent 零配置采集系统、硬件、容器、应用的数千项指标，可常驻运行于物理/虚拟服务器、容器、云部署与边缘/IoT 设备。
- **Azure Data Studio**：开源数据管理工具，可在 Windows、macOS、Linux 上操作 SQL Server、Azure SQL DB 与 SQL DW。
- **Azure SQL Database**：智能、可扩展的云关系型数据库服务，具备 AI 驱动与自动化特性，可按需自动扩缩 Serverless 计算与 Hyperscale 存储。
- **Azure SQL Managed Instance**：托管在 Azure 并置于你网络中的完整托管 SQL Server 数据库引擎实例，便于将本地应用几乎无改动地迁移上云。
- **Azure Synapse Analytics**：无限分析服务，融合企业数据仓库与大数据分析，可用 Serverless 或预配资源按你的方式查询数据。
- **MSSQL for Visual Studio Code**：用于开发 SQL Server、Azure SQL Database、SQL Data Warehouse 的 VS Code 扩展。
- **SQL Server Data Tools (SSDT)**：用于构建 SQL Server 关系数据库、Azure SQL 数据库、AS 数据模型、IS 包、RS 报表的开发工具。
- **Bulk Copy Program (BCP)**：SQL Server 附带的命令行工具，用于快速高效地导入/导出大量数据。
- **SQL Server Migration Assistant**：简化从 Oracle 到 SQL Server、Azure SQL Database、Azure SQL Managed Instance、Azure SQL Data Warehouse 迁移过程的工具。
- **SQL Server Integration Services (SSIS)**：构建企业级数据集成与转换解决方案的开发平台。
- **SQL Server Business Intelligence (BI)**：Microsoft SQL Server 中用于将原始数据转化为商业决策信息的一组工具。
- **Tableau**：关系数据库、云数据库与电子表格的数据可视化软件（2019 年被 Salesforce 收购）。
- **DataGrip**：JetBrains 出品的专业数据库 IDE，提供上下文感知的 SQL 代码补全。
- **RStudio**：R 与 Python 的集成开发环境，带控制台、语法高亮编辑器、绘图、历史、调试与工作区管理工具。
- **MySQL**：完全托管的数据库服务，用于部署基于全球最受欢迎开源数据库的云原生应用。
- **PostgreSQL**：强大、开源的对象关系数据库系统，30+ 年活跃开发，以可靠性、功能丰富与性能著称。
- **Amazon DynamoDB**：键值与文档数据库，任意规模下单毫秒级性能；全托管、多区域、多主、持久，内置安全、备份恢复与内存缓存。
- **Apache Cassandra**：开源 NoSQL 分布式数据库，以线性扩展与在商用硬件/云基础设施上的容错著称，适合关键任务数据。
- **Apache HBase**：开源 NoSQL 分布式大数据存储，支持对 PB 级数据的随机、强一致、实时访问；与 Hadoop MapReduce、Apache Phoenix 配合良好。
- **HDFS (Hadoop Distributed File System)**：在商用硬件上处理大数据集的分布式文件系统，可将单个 Hadoop 集群扩展到数百甚至数千节点。
- **Apache Mesos**：集群管理器，在动态共享节点池上为 Hadoop、Jenkins、Spark、Aurora 等框架提供高效资源隔离与共享。
- **Apache Spark**：统一的大数据分析引擎，内置流处理、SQL、机器学习与图处理模块。
- **ElasticSearch**：基于 Lucene 的搜索引擎，提供分布式、多租户全文搜索与 HTTP 接口，文档为无 schema 的 JSON。
- **Logstash**：事件与日志管理工具，广义上涵盖日志采集、处理、存储与检索的整套系统。
- **Kibana**：Elasticsearch 的开源数据可视化插件，可在索引内容上创建柱状图、折线图、散点图、饼图与地图等。
- **Trino**：分布式 SQL 查询引擎，用于大数据场景，可显著加速 ETL，统一使用标准 SQL，并连接多种数据源与目标。
- **ETL (Extract, Transform, Load)**：从多种来源采集数据、按业务规则转换并加载到目标存储的数据管道。
- **Redis (REmote DIctionary Server)**：开源（BSD 许可）内存数据结构存储，可用作数据库、缓存与消息代理；支持字符串、哈希、列表、集合、有序集合、位图、HyperLogLog、地理空间索引、流等。
- **FoundationDB**：开源分布式数据库，将数据组织为有序 KV 存储并对所有操作使用 ACID 事务；2015 年被 Apple 收购。
- **IBM DB2**：混合数据管理产品集合，提供 AI 驱动的能力以管理结构化与非结构化数据（本地、私有云与公有云）。
- **MongoDB**：文档数据库，以类 JSON 文档存储数据。
- **OracleDB**：功能强大的全托管数据库，帮助开发者以最高可用性、可靠性与安全性管理关键业务数据。
- **MariaDB**：面向现代关键任务应用的企业级开源数据库。
- **SQLite**：实现小型、快速、自包含、高可靠、功能完整的 SQL 数据库引擎的 C 语言库；世界上使用最广泛的数据库引擎，内置于手机与多数计算机中。
- **SQLite Database Browser**：开源 SQL 工具，用于创建、设计、编辑 SQLite 数据库文件，并显示所有已执行 SQL 命令日志。
- **InfluxDB**：开源时序平台，包含存储/查询 API、后台 ETL/监控告警、用户仪表盘、IoT 传感器数据可视化等，并支持处理 Graphite 数据。
- **Atlas**：内存维度时序数据库。
- **CouchbaseDB**：开源分布式多模型 NoSQL 文档数据库，创建带托管缓存的 KV 存储，具备高效查询索引器与 SQL 查询引擎。
- **dbWatch**：面向 SQL Server、Oracle、PostgreSQL、Sybase、MySQL、Azure 的完整数据库监控/管理方案，适合大规模本地/混合/云环境的主动管理与自动化运维。
- **Cosmos DB Profiler**：实时可视化调试器，帮助开发团队洞察应用与 Cosmos DB 的交互，识别十余种可疑行为。
- **Adminer**：SQL 管理客户端，支持 MySQL、MariaDB、PostgreSQL、SQLite、MS SQL、Oracle、Firebird、SimpleDB、Elasticsearch、MongoDB 等。
- **DBeaver**：面向开发者与 DBA 的开源数据库工具，支持 JDBC 兼容数据库（MySQL、Oracle、DB2、SQL Server、Firebird、SQLite、Sybase、Teradata、Hive、Phoenix、Presto 等）。
- **DbVisualizer**：支持 Oracle、Sybase、SQL Server、MySQL、H3、SQLite 等多种数据库的 SQL 管理工具。
- **AppDynamics Database**：Microsoft SQL Server 的管理产品，可监控并趋势化资源消耗、数据库对象、schema 统计等关键性能指标。
- **Toad**：Quest 出品的 SQL Server DBMS 工具集，通过广泛自动化、直观工作流与内置专业知识提升生产力。
- **Lepide SQL Server**：开源 SQL Server 存储管理工具，通过图形界面提供配置与权限变更的完整概览。
- **Sequel Pro**：面向 MySQL 的快速 macOS 数据库管理工具，便于添加数据库、表与行。

---

## 贡献（Contribute）

- 如需为本指南做贡献，请直接提交 Pull Request。

## 许可证（License）

本文档遵循 **Creative Commons Attribution 4.0 International (CC BY 4.0)** 公共许可证分发。

---

## 关于原文仓库

**eBPF (extended Berkeley Packet Filter) Guide** —— 学习面向安全、监控与网络的 eBPF 工具与库。

**Topics（标签）**：log-analysis、sandbox、kubernetes-cluster、tracing、infrastructure-monitoring、performance-monitoring、ebpf、packet-sniffer、network-analysis、xdp、vulnerability-detection、observability、traffic-monitoring、bpf、distributed-tracing、ebpf-programs、falco、real-user-monitoring、kubernetes-security、open-telemetry

