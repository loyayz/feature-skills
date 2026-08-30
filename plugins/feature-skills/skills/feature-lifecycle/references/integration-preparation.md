# 整合准备

只在 feature-review 返回 completed、无阻塞项且能力接口检查通过后执行。这是 Stage 3 与 Stage 4 之间独立的 lifecycle 编排阶段，形成整合证据，不重新评审、修复或运行验证。阶段标识为 integration-preparation，不记入 Stage 3。

1. 保存能力返回的最终内容身份、结论、验证依据和限制，核对当前交付内容仍与其匹配。实际交付证据缺失或矛盾时退回对应能力；临时观测缺项不阻塞整合准备。
2. 将最终快照的规范化清单冻结为 `stage-4-delivery-manifest`。清单必须覆盖相对当前 `delivery-base-sha` 的完整最终交付：合并 feature 历史中已提交的增改删、当前 tracked 未提交增改删和未跟踪交付路径，再排除已登记过程文件；不能只读取当前工作树状态、当前 HEAD 之后的 diff、staged diff 或其中任一子集。记录本次清单对应的 `delivery-base-sha`，保留精确仓库相对路径、`added | modified | deleted` 状态、每个现存路径的 SHA-256 或删除标记，以及清单整体哈希。冻结后到单提交固化前只按该清单核对，不从 staged diff、提交 diff 或 rename detection 重新推导交付集合；后续 rebase 成功且无冲突时按 Stage 4 规则推进交付基线并刷新 manifest。
3. 依据当前 `delivery-base-sha` 和 manifest 形成最终实际 diff、路径集合，引用能力返回的既有生产文件影响说明；不重新分析业务控制流或裁决影响。
4. 核对过程文件没有进入交付提交，并记录需要在最终结果中说明的流程文档、报告和特殊资源入口。不建立清理白名单，也不穷举隔离 worktree 内的 ignored 构建输出；合并成功后删除整个隔离 worktree 即完成过程文件清理。
5. 在流程文档记录当前本地 base、feature HEAD、manifest、最终评审与验证结果、共享资源或容量影响，以及未执行的压测和运行验证。
6. 形成 Stage 4 merge-ready 授权所需的分支、worktree、单提交目标和不可恢复清理披露，但此时不询问授权；只有 Stage 4 自动固化和必要对齐完成、唯一剩余写操作为 `merge --ff-only` 时才询问一次。

本准备不执行 squash、commit、rebase、merge 或清理。Stage 4 在每个写操作和删除前刷新会变化的 Git 状态与路径安全检查。
