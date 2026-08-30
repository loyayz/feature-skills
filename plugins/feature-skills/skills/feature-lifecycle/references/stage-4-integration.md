# Stage 4：自动固化、合并授权与清理

本文件是 Stage 4 Git 固化、最终对齐、唯一合并授权、fast-forward、完成态观察和清理的唯一 owner。评审能力已返回完成且无阻塞项，独立整合准备完成后才进入；Stage 4 不新增评审、修复循环或最终工程验证。

Stage 4 的正常路径自动推进到 `merge-ready` 状态：feature 已固化为单提交、针对当时本地 base 的必要 rebase 已完成、交付内容仍匹配 整合准备冻结的 `stage-4-delivery-manifest`，此时唯一剩余的仓库变更是把该提交合并到本地 base。首次到达这里时只请求一次用户授权；授权后即使本地 base 前进，也自动重新对齐并继续合并，不再次询问。合并成功后的完成态观察和已披露清理自动执行，不增加第二次确认。

## 快速路径不变量

| 事件 | 处理 |
|---|---|
| Stage 3 退出后交付内容未变 | 复用 `final-review-snapshot`、`stage-4-delivery-manifest` 和最终工程验证证据 |
| 当前本地 base 已是 feature 的祖先 | 跳过 rebase |
| 当前本地 base 不是 feature 的祖先，rebase 无冲突 | 对该 base SHA 自动执行一次 rebase，复用 Stage 3 证据 |
| rebase 发生冲突 | 立即 abort；回 Stage 2 解决，再完整经过 Stage 3 |
| rebase 或其他动作需要改变业务语义、契约或授权 | 回 Stage 1 重新收敛，再经过 Stage 2 和 Stage 3 |
| merge 授权后 base 前进或无冲突 rebase 改变提交身份 | 授权保持有效；自动刷新 merge-ready 快照并继续合并，不再次询问 |
| 授权后的目标 base 分支或业务交付内容变化 | 授权失效；回对应 owner 重新收敛，之后再次到达 merge-ready 才询问 |
| 授权后只发现本流程生成的普通 ignored 输出 | 原授权继续有效；更新审计摘要并自动清理，不再次询问 |
| fast-forward 后 feature HEAD 是当前 base 的祖先 | 本 feature 已整合；后继提交属于其他任务 |
| feature HEAD 不是当前 base 的祖先 | 授权前或授权后都自动对齐；只有冲突或真实安全失败才暂停 |

Stage 4 的 Git 状态、路径、祖先关系和提交身份检查会立即决定下一写操作，且写操作前必须使用最新状态，因此由主代理直接完成，不新建 Stage 4 低成本代理。连续只读事实在没有写操作隔开时一次收敛读取；每个执行阶段只包含“最新前置检查 + 一个 Git 写操作 + 该写操作的直接后置断言”，不得把同一写操作拆成多次工具往返。多个 Git 写操作仍保持独立阶段；后置断言失败时不得重复已经成功的写操作。

## 进入审计与自动准备

进入后读取整合准备保存的交付证据，确认：

- review 已对 `final-review-snapshot` 对应内容返回完成且无阻塞项，实际验证状态与限制已保存。
- 交付所需的内容身份、验证依据和授权事实可核对；临时观测台账及其缺项不参与进入判断。
- 生命周期文档中的 `stage-4-delivery-manifest` 包含精确仓库相对路径、`added | modified | deleted` 状态、每个现存路径的 SHA-256 或删除标记，以及规范化清单整体哈希。
- 当前非过程交付路径与冻结 manifest 精确相等：按 manifest 路径核对内容，同时从当前状态验证不存在 manifest 之外的新增、修改或删除；不得根据 staged diff、提交 diff 或 rename detection 重新枚举一份替代交付集合。
- 实际路径与能力返回的修改清单一致，授权记录未变化；业务影响与受保护行为以能力结论为准，发现明确矛盾时退回该能力。
- 过程文件没有进入交付提交；合并成功后通过删除整个已注册隔离 worktree 清理，不建立或核对清理白名单。
- 原工作区、base、feature 分支和 worktree 身份仍与生命周期记录一致。

业务交付内容或 整合准备冻结范围已变化时返回 Stage 3；业务语义、契约或授权发生变化时返回 Stage 1。仅提交 SHA、base 带入的整文件内容、过程文档或普通 ignored 构建输出变化不使评审证据失效；刷新 manifest 或状态摘要即可。

审计通过后不等待用户确认，直接执行下述单提交固化和最终对齐。若 feature 分支已推送，自动动作仍只改写本地 feature 历史，不执行 push 或远端同步；远端分歧进入 merge-ready 披露。

## 自动固化为单提交

主代理直接刷新原工作区和 feature worktree 状态。原工作区必须仍在 `<base-branch>` 且没有本流程外修改；feature worktree 的交付内容必须匹配 manifest，过程文件不得进入暂存区。ignored 构建、测试和缓存输出不需要枚举或登记。任何指向 worktree 外部的 junction、symlink、mount 等链接必须先按已验证的非递归方式解绑，禁止递归触碰外部目标。禁止 stash、丢弃或为了干净状态提前清理。

先确认记录的 `<delivery-base-sha>` 是 feature HEAD 的祖先且与 manifest 基线一致；基于该 SHA 依次执行：soft reset 折叠已提交的 feature 历史；从 index 取消暂存所有 tracked 过程路径；按冻结 manifest 的精确路径显式暂存全部 `added | modified | deleted` 交付；核对 staged 路径精确等于 manifest、与过程清单无交集，并确认不存在 manifest 外交付变化；最后创建唯一 feature commit。soft reset 只改变既有提交的 index 状态，不会自动暂存当前 tracked 未提交、未跟踪或删除的交付；其后 staged 集合只是 manifest 子集时，不得判定为内容漂移或重新推导交付集合，必须完成上述显式暂存后再执行完整断言。每个写操作按“前置检查 + 单个写操作 + 后置断言”执行；没有写操作隔开的只读核对合并为一次读取。最终必须证明 `<delivery-base-sha>` 后只有一个 feature commit，提交路径与过程文件清单无交集，当前内容逐项匹配冻结的 `stage-4-delivery-manifest`，且不存在 manifest 外交付变化。不得因 reset、暂存、当前 index、staged diff 或 Git rename 展示变化而重新生成路径集合或内容身份。历史变换只改变提交身份时继续复用 Stage 3 证据；交付内容变化则返回 Stage 3。

## 自动最终对齐

“最新 base”只指执行时本地 `<base-branch>` 引用，不执行 `fetch`、`pull` 或远端同步。先直接检查当前本地 base 是否已经是 feature HEAD 的祖先：

- **已经是祖先：** 跳过 rebase。
- **不是祖先：** 在 feature worktree 对当前本地 base SHA 自动执行一次 rebase。Stage 4 对同一 base SHA 不重复自动 rebase；base 前进到新的 SHA 时，这是一项新的对齐事实，可以再自动执行一次。

rebase 成功且无冲突时就留在 Stage 4 继续下一步：不返回 Stage 3，不重新调用 `feature-review`，也不运行构建、测试、lint 或 E2E。确认目标 SHA 已是 feature 祖先后，将 `delivery-base-sha` 更新为该 SHA，并按相对新基线的净交付刷新 manifest 和 merge-ready 快照；不得把 base 自身的增改删计入交付。rebase 出现冲突时才离开 Stage 4。

rebase 出现冲突时不得在 Stage 4 解决、评审或追加验证。立即执行 `rebase --abort` 并核对 feature 回到 rebase 前提交；保留本次冲突目标 SHA 和证据，保持 `delivery-base-sha` 不变并回 Stage 2。Stage 2 显式调用 `feature-dev`，传入冲突证据、固定目标 SHA、已固化 spec 和授权范围，授权它重新发起并完成针对该 SHA 的 rebase 冲突恢复，在最终内容稳定后完成受影响验证；本次恢复的差异核对以该目标 SHA 为固定比较基线。这是授权的冲突恢复，不受 Stage 4 同一 SHA 不重复自动 rebase 的限制。能力返回后，lifecycle 核对 rebase 已完整结束且目标 SHA 已是 feature 祖先，才将 `delivery-base-sha` 更新为该目标，再完整经过 Stage 3。恢复失败或再次 abort 时不推进基线；不能仅在旧基线上修改冲突文件就宣告对齐完成。后续评审、manifest、soft reset 和单提交证明均相对更新后的交付基线，`initial-base-sha` 保持不变。若冲突揭示业务、契约或授权变化，则改回 Stage 1。正常路径不为理论冲突预付额外评审。

上述结构或内容检查失败时离开 Stage 4，按变化性质返回 Stage 3 或 Stage 1。本地 base 在检查期间再次移动、但目标 base 分支、冻结 manifest 和过程文件清单未变时，刷新到新的 base SHA 并重复本节；此前针对旧 SHA 的 rebase 不阻止对新 SHA 自动重新对齐，也不产生新的用户确认。

## Merge-ready 快照与唯一授权

最终对齐通过后保存当前 `merge-ready` 操作快照，至少包含 `<base-branch>`、当前 base SHA、`delivery-base-sha`、`<feature-branch>`、`<feature-head>`、worktree、单提交证明和 `stage-4-delivery-manifest` 整体哈希。首次到达这里时不得再有 squash、commit、rebase、代码修改、评审或最终工程验证待执行；唯一未执行的仓库整合写操作必须是 `merge --ff-only <feature-branch>`。base 前进后的无冲突重新对齐可以刷新 base SHA、`<feature-head>`、单提交证明和 manifest，不改变授权范围。

使用整合准备保存的能力影响说明，一次披露：精确 base 与 feature 提交、既有生产文件的修改或删除及其控制流、状态、事务、异常、补偿、协议或权限影响，共享资源和容量影响，未执行的压测或运行验证，远端分歧，以及合并成功后会自动删除 feature 分支、worktree 和“过程文件清单”中的全部未提交过程文件；这些过程文件无法从 Git 恢复。

随后只询问一次：

> `<feature-branch>` 已自动固化并对齐到本地 `<base-branch>`，当前 merge-ready 提交为 `<feature-head>`。是否执行唯一剩余的 `merge --ff-only` 合并？成功后将自动删除该开发分支、worktree 及已披露的全部过程文件。

用户对该问题的明确肯定答复授权：把当前交付内容合并到指定 `<base-branch>`，并在成功后删除 feature 分支和整个隔离 worktree。base SHA、`<feature-head>`、单提交证明、无冲突 rebase 后刷新的 manifest 和 worktree 内后来出现的 ignored 输出都不改变授权，不得因此重新询问。在问题出现前给出的“继续”、一般批准或生命周期启动授权不能替代。用户拒绝或暂缓时，报告 merge-ready 快照、验证结果和保留资产后结束；不得合并或清理，但不撤销已经完成的本地单提交固化和最终对齐。

## Fast-forward 整合

收到授权后，在原工作区一次刷新并确认：仍位于已授权的 `<base-branch>`、工作区状态安全、业务交付内容未变化、过程文件没有混入提交。目标 base 分支或业务交付内容变化才使授权失效；无冲突 rebase、manifest 刷新、过程文档更新或新增 ignored 生成物不得触发再次询问。

授权范围保持不变时，检查当前 base 是否是 feature HEAD 的祖先。若 base SHA 或 `<feature-head>` 只是因 base 前进、单提交固化或无冲突 rebase 变化，授权继续有效；按“自动最终对齐”更新操作快照，达到最新 merge-ready 后直接执行 `merge --ff-only <feature-branch>`，不重新披露或询问。写操作退出 0 后立即检查当前 base：

- base HEAD 等于 `<feature-head>`，或 `<feature-head>` 是当前 base 的祖先时，本 feature 已整合；后继提交属于其他任务，不扩展评审或验证。
- fast-forward 失败且只读刷新证明本地 base 又前进、授权范围仍未变化时，保留授权并自动重新对齐到新的 base SHA 后重试；不得重复针对同一 base SHA 的失败写操作。
- 其他 fast-forward 失败时暂停并保留 feature 分支、worktree 和过程文件，只记录当前 base、feature HEAD 和最小错误证据；目标分支、manifest 和过程文件清单未变化时，继续处理无需再次授权。

Stage 4 不重跑最终工程验证。无冲突历史变换和 fast-forward 复用 Stage 3 证据；任何交付内容变化都必须离开 Stage 4，重新经过其 owner 阶段。

## 完成态观察与自动清理

整合祖先检查通过后，清理前再次读取当前 base 并验证 `<feature-head>` 仍是其祖先。把最终 spec 路径从 worktree 改写为 `<repo-root>` 下相同仓库相对路径，确认目标是已整合的 Stage 1 Markdown spec，然后产生一次 `completed / integrated` 观察点；观察结果不阻塞清理。

主代理确认待删路径是本流程注册的隔离 worktree且不是仓库根目录；不为其中的过程文件或 ignored 生成物建立清理白名单。任何指向 worktree 外部的链接都必须先验证目标并非递归解绑，不能随目录递归删除。

解析并验证 `<worktree-path>` 是已注册的 feature worktree，且不是 `<repo-root>` 或宽泛目录。

从原工作区依次执行并检查：强制移除该 worktree、删除已整合 feature 分支、prune worktree 元数据。每个删除动作前都重新确认绝对目标并已处理外部链接。合并成功后的这些动作不再请求用户确认。

最终输出 base、整合 commit、删除的分支和 worktree、`completed / integrated` 生命周期事实，并说明过程文件已随 worktree 删除。另用一行紧凑说明是否发生 Stage 回退、Stage 4 是否复用既有验证，以及清理是否遇到外部链接或失败；不输出临时目标观测明细。
