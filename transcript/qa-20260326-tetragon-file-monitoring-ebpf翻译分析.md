# QA 记录：Tetragon eBPF 文件监控翻译与深度分析

> 日期：2026-03-26

## 用户请求

翻译并深度分析 Isovalent 的文章 "File Monitoring with eBPF and Tetragon (Part 1)"，本地存档为 `origin/Message from Welcome to Isovalent!.mhtml`。

## 处理过程

1. 在项目中定位到 MHTML 文件：`origin/Message from Welcome to Isovalent!.mhtml`（22MB，包含图片资源）
2. 分段读取并解码 quoted-printable 编码的 HTML 内容
3. 提取文章全部技术内容（含代码示例、策略 YAML、事件输出 JSON）
4. 完成翻译、总结和深度分析
5. 与之前分析的 Sysdig FIM 进行对比

## 输出文件

- `ebpf/tetragon-file-monitoring-with-ebpf-part1-翻译与深度分析-20260326.md`

## 关键结论

### Tetragon FIM 的三大技术创新
1. 钩入 LSM `security_*` 函数避免 TOCTOU 竞态攻击
2. 内核级过滤 + 内联执行（可直接阻止文件操作）
3. Inode-based 监控防止路径绕过（硬链接/绑定挂载）

### 与 Sysdig FIM 的核心差异
- Tetragon 支持读取检测和操作阻止，Sysdig FIM 不支持
- Tetragon 企业版支持 inode-based 防绕过，Sysdig FIM 仅支持路径匹配
- Sysdig FIM 更易于配置（GUI），Tetragon 需要内核知识
