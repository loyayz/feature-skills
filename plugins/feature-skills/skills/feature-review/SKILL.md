---
name: feature-review
description: Use only when the user explicitly requests feature-review, or a user-started feature-lifecycle invokes it, to review a concrete change and perform authorized repairs or validation. Do not select it for ordinary task matching.
---

# Feature Review

Review a concrete change against the current user request, finalized implementation-ready specification when available, project rules, and the real implementation. This skill owns review snapshots, dual-axis review, one independent reviewer, candidate adjudication, authorized repairs, re-review, and validation evidence.

Only run when the user explicitly requests this skill, or when a feature-lifecycle workflow explicitly started by the user is actively invoking it. Ordinary task matching, recommendations from other skills, and discussing, reviewing, or editing this skill are not execution authorization. Without either authorized source, do not enter the workflow. Catalog visibility is not permission to execute; the caller check is only an entry gate and introduces no orchestration responsibilities.

The authorized invocation defines the scope:

- A request to review, audit, inspect, or report is read-only.
- Repair code only when the current explicit invocation asks to fix, repair, or complete review fixes.
- Run engineering validation only when the current explicit invocation requests it, applicable project gates require it, or it is necessary to confirm an authorized repair. Reuse valid existing evidence before running commands.

Read [the review workflow](references/review.md) completely before establishing the review snapshot.

## 低成本执行

评审范围、双轴判断、finding 裁决、修复和验证范围由本 skill 的主代理负责；独立 reviewer 只承担评审工作流定义的一次隔离评审。对范围与命令已经确定的快照哈希、机械验证和只读核对，执行前先判断下放资格：命令非交互、失败能原样返回且副作用仅为只读或可重建产物时，默认交给低成本代理；微小且立即完成的检查、槽位被实际工作占满或宿主无法可靠下放时直接执行。首次下放前完整读取 [低成本代理协议](references/low-cost-execution-agent.md)。没有实际下放就不读取；当前主任务已经读取相同协议标识时不重复读取。

只有主代理调度低成本代理。独立 reviewer 不得派生低成本代理，低成本代理也不参与 finding 判断或修复。
