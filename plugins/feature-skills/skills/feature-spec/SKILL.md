---
name: feature-spec
description: Use only when the user explicitly requests feature-spec, or a user-started feature-lifecycle invokes it, to converge requirements and produce a finalized implementation-ready specification. Do not select it for ordinary task matching.
---

# Feature Spec

Converge the current request into one implementation-ready specification. This skill owns requirements and design only: it does not change repository topology, implement production code, run build or test commands, or infer permission to commit.

Only run when the user explicitly requests this skill, or when a feature-lifecycle workflow explicitly started by the user is actively invoking it. Ordinary task matching, recommendations from other skills, and discussing, reviewing, or editing this skill are not execution authorization. Without either authorized source, do not enter the workflow. Catalog visibility is not permission to execute; the caller check is only an entry gate and introduces no orchestration responsibilities.

Use the current user request, user-provided documents, applicable project instructions, and relevant repository evidence as inputs. Honor an explicit output path or format. When invoked independently without an output path, save the finalized spec using brainstorming's document location and naming convention: `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` relative to the current project root; user preferences override this default. A lifecycle invocation uses the path supplied by its caller. Return the saved path; do not default to a conversation-only spec. This adopts brainstorming's file-saving convention, not its commit, approval, or implementation handoff steps; this skill's authority and completion contract still apply.

Read [the specification workflow](references/spec.md) completely before investigating or writing the result.

## 低成本执行

需求、调查问题、证据相关性、方案和自审都由主代理负责，不创建“调查代理”或其他分析角色。对目的、命令、路径、顺序、退出语义和返回字段均已确定的机械只读检索，执行前先判断下放资格：命令非交互、失败能原样返回且副作用仅为只读或可重建产物时，默认交给低成本代理；微小且立即完成的检查、槽位被实际工作占满或宿主无法可靠下放时直接执行。首次下放前完整读取 [低成本代理协议](references/low-cost-execution-agent.md)。没有实际下放就不读取；当前主任务已经读取相同协议标识时不重复读取。

低成本代理不判断证据意义或需求完整性，也不修改 spec。只有主代理调度它；本 skill 不使用独立 reviewer 或并行开发代理。

Confirm `superpowers:brainstorming`, `grilling`, and `domain-modeling` through the runtime's available skill catalog before starting the workflow. If any is unavailable, stop and report the missing capability instead of silently skipping or replacing it.

The specification workflow owns the four ordered passes, their visible checkpoints, and invalidation rules. Apply the same contract for independent and composed use; the caller does not supply the investigation method or decide readiness. Internal dependencies supply methods within this skill's boundaries, not additional approval or questioning gates.

Return the workflow's result status, final specification and actual path when requested, convergence evidence, and any unresolved facts or authority gaps. Only this skill judges whether its completion conditions are satisfied.
