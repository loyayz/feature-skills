# Rebase 冲突恢复

仅在 Stage 4 的 rebase 发生冲突、已执行 abort 并确认 feature 恢复到 rebase 前提交后读取。abort 失败时保留现场并暂停，不进入本流程。正常或无冲突 rebase 不读取本文件。

本文件是 [Stage 4](stage-4-integration.md) 的条件处理分支，不是独立 Skill；lifecycle 只负责路由和基线核对，冲突解决与受影响验证由 feature-dev 负责。

1. 保留冲突目标 base SHA、rebase 前 feature 提交及冲突证据，保持 `delivery-base-sha` 不变，回 Stage 2。
2. 显式调用 feature-dev，传入固定目标 SHA、冲突证据、已固化 spec 和授权范围，授权它重新发起并完成针对该 SHA 的 rebase 冲突恢复。恢复期间的差异核对以该目标 SHA 为固定基线；最终内容稳定后完成受影响验证。这是恢复任务，不受 Stage 4“同一 SHA 不重复自动 rebase”的限制。
3. 能力返回后，核对 rebase 已完整结束且固定目标 SHA 已是 feature 祖先，才推进 `delivery-base-sha`。恢复失败或再次 abort 时保留旧基线；仅在旧基线上修改冲突文件不能算已对齐。
4. 恢复成功后完整经过 Stage 3 和整合准备。后续评审、manifest、soft reset 及单提交证明使用更新后的交付基线，`initial-base-sha` 保持不变；然后重新进入 Stage 4。合并授权是否有效按 Stage 4 的共同约束判断。

任何阶段的新事实要求改变业务语义、契约或授权时，回 Stage 1 收敛，再经过开发和评审；不得把这些变化当作纯冲突消解自动处理。
