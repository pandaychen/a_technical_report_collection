# QA 记录：Linux 内核路径名查找（Pathname Lookup）文章翻译

- **日期**：2026-06-15
- **类型**：技术文章翻译
- **原文链接**：https://www.kernel.org/doc/html/latest/filesystems/path-lookup.html

## 问题

用户请求完整且详细地翻译 Linux 内核官方文档中关于路径名查找（Pathname Lookup）的技术文章。

## 完成内容

1. 完整翻译了原文三大章节：
   - **路径名查找概述**：路径分量解析、dcache 原理、REF-walk 并发控制（d_lockref / d_lock / rename_lock / i_rwsem / mnt_count / mount_lock / RCU）、nameidata 结构、最终分量处理、重新验证与自动挂载
   - **RCU-walk**：与 REF-walk 的角色划分、seqlock 机制（mount_lock/m_seq、d_seq/nd->seq）、unlazy_walk()/complete_walk() 切换、文件系统中的注意事项、两种设计模式
   - **符号链接处理**：符号链接栈、缓存生命周期、跟随符号链接、最终分量中的符号链接、atime 更新、各类标志（全局状态/解析限制/最终分量）

2. 补充了 4 个 Mermaid 流程图：
   - 路径名查找总体流程（RCU-walk → REF-walk → REVAL 回退链）
   - walk_component() 内部逻辑
   - RCU-walk 与 REF-walk 并发控制对比
   - 符号链接栈处理流程

## 输出文件

- `linux-kernel/linux-pathname-lookup-翻译-20260615.md`
