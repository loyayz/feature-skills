# Stage 4：自动固化、合并授权与清理

本文件拥有 Stage 4 的 Git 固化、最终对齐、唯一合并授权、fast-forward、完成态观察和清理。review 已返回完成且无阻塞项、独立整合准备已完成后才进入。正常路径为：核对交付 → 单提交固化 → 本地对齐 → merge-ready 授权 → 合并与完成态更新 → 清理。

## 共同约束

- **执行与证据：** 主代理直接执行，不新建 Stage 4 低成本代理，不新增评审、修复循环或工程验证。交付内容未变时复用 Stage 3 证据；仅提交身份、无冲突 rebase 带入的 base 内容、过程文档或普通 ignored 输出变化不使证据失效。
- **写操作：** 每个阶段使用“最新前置检查 + 一个 Git 写操作 + 直接后置断言”。无写操作隔开的只读检查合并读取，多个 Git 写操作保持独立阶段；后置断言失败不得重复已经成功的写操作。
- **本地范围：** base 指执行时本地 `<base-branch>`，不执行 fetch、pull、push 或远端同步。已推送的 feature 仍只改写本地历史，远端分歧在授权前披露。
- **交付集合：** 以整合准备冻结的 `stage-4-delivery-manifest` 为准，核对路径、状态、内容及集合外变化；不得用 index、staged diff、提交 diff 或 rename 展示重新推导替代集合。无冲突 rebase 后的更新由“自动最终对齐”负责。
- **合并授权：** 首次 merge-ready 才询问一次；明确肯定答复授权合并当前业务交付到指定 base 分支，并在成功后删除 feature 分支、整个隔离 worktree 及已披露过程文件。此前一般“继续”或 lifecycle 启动不替代此授权。仅目标 base 分支或业务交付内容变化使授权失效；base SHA、feature SHA、单提交证明、无冲突 rebase 后刷新的 manifest、过程文档及普通 ignored 输出变化均沿用授权。
- **安全与观测：** 禁止 stash、丢弃用户改动或为了干净状态提前清理。过程文件不得进入交付提交，不建立 ignored 输出清理白名单。临时观测缺项不阻塞交付；实际身份、验证依据或权限缺口仍须处理。

## 异常路由

仅在出现对应事实时执行；正常路径不预读冲突恢复说明。

| 事实 | 处理 |
|---|---|
| 业务语义、契约或授权变化 | 返回 Stage 1 |
| 业务交付内容或冻结范围改变，但无上述变化 | 返回 Stage 3 |
| 能力返回的交付证据缺失或矛盾 | 把具体缺口退回对应能力，不自行重做专业判断 |
| 目标 base 分支改变 | 暂停整合，回 Stage 1 确认目标与授权 |
| rebase 冲突 | 立即 abort 并核对恢复到 rebase 前提交；成功后按[冲突恢复](rebase-conflict-recovery.md)回 Stage 2 |
| abort、身份或路径安全检查失败 | 保留现场与最小证据并暂停，不推进交付基线或执行后续写操作 |
| fast-forward 失败，且只读刷新证明 base 又前进 | 按“自动最终对齐”处理新的 base SHA 后重试；不重复针对同一 SHA 的失败写操作，授权按共同约束判断 |
| 其他 Git 写操作失败 | 保留 feature、worktree、过程文件及当前 base/HEAD/错误，暂停；后续恢复仍按原授权边界处理 |
| 用户拒绝或暂缓合并 | 报告 merge-ready、验证结果和保留资产后停止，不撤销已完成的本地固化与对齐 |

## 进入审计与自动准备

读取整合准备保存的证据，一次确认：

- `final-review-snapshot` 对应评审已完成且无阻塞，验证结果、限制及授权事实可核对。
- manifest 记录 `delivery-base-sha`、精确仓库相对路径、`added | modified | deleted`、现存文件原始字节 SHA-256 或删除标记，以及规范化清单整体哈希。
- 当前非过程交付路径与 manifest 精确相等，内容逐项匹配，无集合外新增、修改或删除；实际范围与能力返回一致。业务影响及受保护行为使用能力结论。
- 原工作区、base、feature 分支和 worktree 身份仍与流程记录一致。

通过后自动固化和对齐，不请求中间确认；失败按异常路由处理。

## 自动固化为单提交

刷新原工作区与 feature 状态：原工作区仍在目标 base 分支且没有本流程外修改，feature 交付匹配 manifest。外部链接按下文安全清理的非递归解绑要求处理，普通 ignored 构建输出无需枚举或登记。

确认 `delivery-base-sha` 是 feature HEAD 的祖先，且与 manifest 基线一致，然后按写操作约束依次执行：

1. 对该基线 soft reset，折叠已提交的 feature 历史。
2. 从 index 取消暂存所有 tracked 过程路径。
3. 按 manifest 精确路径显式暂存全部增改删交付，核对 staged 集合精确等于 manifest、与过程路径无交集且没有集合外交付变化。
4. 创建唯一 feature commit；证明基线后仅一个提交、提交路径与 manifest 相同且不含过程文件，当前交付内容仍逐项匹配。

soft reset 不会自动暂存当前未提交、未跟踪或删除的交付。必须完成第3步后再做完整 staged 集合断言，不能把中间的 manifest 子集判为内容漂移。

## 自动最终对齐

读取当前本地 base SHA：

- 已是 feature HEAD 的祖先：跳过 rebase。
- 尚不是祖先：在 feature worktree 对该 SHA 自动 rebase。同一 SHA 不重复自动 rebase；base 前进到新的 SHA 时可再次对齐。
- rebase 冲突或失败：按异常路由处理，不在 Stage 4 解决冲突。

无冲突成功后，确认目标 SHA 已是 feature 祖先，才推进 `delivery-base-sha`。按相对新基线的净交付刷新 manifest 及已有 merge-ready 快照，排除 base 自身的增改删，保持 `initial-base-sha` 不变；留在 Stage 4 继续，复用评审与工程证据。

检查期间 base 再次前进时，按新的 SHA 重复本节；是否仍有合并授权只按共同约束判断。

## Merge-ready 快照与唯一授权

对齐后保存 base 分支及 SHA、`delivery-base-sha`、feature 分支及 HEAD、worktree、单提交证明和 manifest 整体哈希。此时不得再有固化、对齐、代码修改、评审或验证待执行，唯一剩余的仓库整合写操作是 `merge --ff-only <feature-branch>`。

首次授权前，引用能力影响说明一次披露：精确 base/feature 提交，既有生产文件修改或删除及其控制流、状态、事务、异常、补偿、协议或权限影响，共享资源和容量影响，未执行的压测或运行验证，远端分歧，以及合并后的分支、worktree 和全部未提交过程文件清理；过程文件无法从 Git 恢复。

> `<feature-branch>` 已固化并对齐到本地 `<base-branch>`，当前提交为 `<feature-head>`。是否执行 `merge --ff-only` 合并？成功后自动删除开发分支、整个隔离 worktree 及已披露过程文件。

已有有效授权时只刷新变化后的操作快照，不重复披露或询问。

## Fast-forward 整合与完成态

在原工作区刷新前置事实：仍在已授权 base 分支、工作区安全、交付内容匹配 manifest，过程文件未混入提交，授权有效。base 不再是 feature 祖先时先按“自动最终对齐”恢复 merge-ready，再执行 `merge --ff-only <feature-branch>`。

成功后立即确认 base HEAD 等于 feature HEAD，或 feature HEAD 已是 base 的祖先；后继提交属于其他任务，不扩展评审或验证。失败按异常路由处理。

祖先检查通过后、删除过程文件前，原位更新流程文档为 `completed / integrated`、清理待执行，替换旧 merge-ready、待授权和待合并动作。最终 spec 路径改为原仓库下已整合的同一 Stage 1 Markdown spec，并产生一次完成态观察；观察结果不阻塞清理。

## 安全清理与最终输出

清理前再次读取 base 并验证 feature HEAD 仍是其祖先。解析待删绝对路径，确认是本流程注册的 feature worktree，且不是仓库根或宽泛目录。外部 junction、symlink、mount 等链接须先验证目标，以已验证的非递归方式解绑，禁止递归触碰外部目标。

从原工作区依次执行并检查：强制移除整个 worktree、删除已整合 feature 分支、prune worktree 元数据。每个删除动作前重新确认绝对目标、身份及外部链接已处理。

最终输出 base、整合 commit、已删除分支和 worktree、`completed / integrated` 事实及过程文件已删除；另用一行说明 Stage 回退、既有验证复用和外部链接或清理失败情况，不输出临时目标观测明细。
