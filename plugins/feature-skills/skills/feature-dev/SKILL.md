---
name: feature-dev
description: Use only when the user explicitly requests feature-dev, or a user-started feature-lifecycle invokes it, to implement a finalized specification and obtain affected-scope validation evidence. Do not select it for ordinary task matching.
---

# Feature Dev

Implement an implementation-ready specification in the current task. This skill owns code changes, ordinary test decisions, and affected-scope validation.

Only run when the user explicitly requests this skill, or when a feature-lifecycle workflow explicitly started by the user is actively invoking it. Ordinary task matching, recommendations from other skills, and discussing, reviewing, or editing this skill are not execution authorization. Without either authorized source, do not enter the workflow. Catalog visibility is not permission to execute; the caller check is only an entry gate and introduces no orchestration responsibilities.

Require a finalized implementation-ready specification or an equivalently precise current requirement. If a missing decision would change business behavior, authorization, an external contract, or the minimum production design, stop and report the exact requirement gap instead of inventing it.

Read [the development workflow](references/development.md) completely before modifying files.

## 实现方式

优先遵守用户明确指定的执行方式或上限。默认由主代理完成实现。只有子任务不需要等待、修改或协调本次其他子任务的实现，即可独立完成并验收时，才使用开发代理。需要共同调整接口、状态或调用链的工作由主代理按依赖顺序完成；文件不重叠或预先约定接口，不代表任务独立。已确定命令的机械检索和验证按下述低成本执行规则下放。

## 低成本执行

实现策略、技术映射、批次、普通测试选择和验证范围由本 skill 的主代理负责。对范围与命令已经确定的机械构建、测试、静态检查和只读核对，执行前先判断下放资格：命令非交互、失败能原样返回且副作用仅为只读或可重建产物时，默认交给低成本代理；微小且立即完成的检查、槽位被实际工作占满或宿主无法可靠下放时直接执行。首次下放前完整读取 [低成本代理协议](references/low-cost-execution-agent.md)。没有实际下放就不读取；当前主任务已经读取相同协议标识时不重复读取。

只有主代理调度低成本代理。并行开发代理不得派生低成本代理，也不能把自己的实现责任转交给低成本代理。
