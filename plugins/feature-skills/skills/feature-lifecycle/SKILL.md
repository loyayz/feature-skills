---
name: feature-lifecycle
description: Use when the user explicitly invokes feature-lifecycle for isolated feature delivery from specification through development, review, integration, and cleanup; do not invoke it for ordinary feature requests.
---

# Feature Lifecycle

## 启动与职责

仅当用户明确要求使用 `feature-lifecycle` 或输入 `$feature-lifecycle` 时启动。普通实现请求、讨论、评审或修改本 skill、过去启动过流程，以及其他 Skill 的推荐或依赖声明，都不构成启动授权。用户仅调用外层集成时不得自行启动本 skill。未获启动授权时不检查依赖、不创建资产、不执行 Stage；已由用户启动的当前流程可按其授权继续推进。

本 skill 只拥有隔离初始化、Stage 路由、过程资产、Git 整合、授权、安全清理和外层观察。三个能力独立负责自己的依赖、方法与完成判断；调用只传目标、事实、路径、授权和已有证据，不传内部算法或 Stage 语义。

## Stage 1

每次显式调用先做初始化预检；原工作区干净且检查通过后才创建独立新流程。既有流程文档、feature 分支或 worktree 不作为新流程入口；目标冲突时披露并暂停。

从当前 catalog 的名称和描述解析直接依赖 `feature-spec`、`feature-dev`、`feature-review`，可用性检查不读取三个能力正文。优先使用相同命名空间的实际标识；裸标识对应裸标识。必需能力不可用时暂停，不内联替代。只在实际调用当前能力时完整读取其入口和所需 reference；等待当前能力结果期间不预加载下一能力。内部依赖由能力自查。

初始化前完整读取 [编排契约](references/lifecycle-orchestration-contract.md) 和 [Stage 1 初始化](references/stage-1-initialization.md)。初始化完成后显式调用 `feature-spec`，传入当前需求、用户指定资料、已取得事实和 `docs/superpowers/specs/YYYY-MM-DD-<feature-slug>-design.md` 输出路径。需求调查、范围完整性和收敛方法完全由它负责。

按编排契约消费返回结果。`implementation-ready` 且接口检查通过后，只提交最终 spec，记录实际路径、内容身份、授权责任和未验证项，产生 spec 路径观察点并自动进入 Stage 2。需要用户决定或授权时只询问能力返回的最小缺口。

后续回到 Stage 1 时复用本次 worktree 和流程文档，把新事实与当前 spec 交给能力重写；不重新初始化或创建第二份 spec。能力完成后提交当前 spec，再按顺序继续。

## Stage 2

显式调用 `feature-dev`，传入实施就绪 spec、仓库、允许责任范围、受保护行为和适用项目指令。执行方式、技术映射、批次、代理预算和验证由它决定。

返回需求变化时回 Stage 1；返回 `completed` 且接口检查通过后，保存实际修改、结果、验证证据及限制，产生实现进度观察点，自动进入 Stage 3。授权缺口、执行失败与用户停止边界按编排契约处理。

## Stage 3

显式调用 `feature-review`，传入当前需求、最终 spec、固定的 `delivery-base-sha`、相对该基线的完整实际 diff、当前内容身份、已有验证证据和 `docs/review/YYYY-MM-DD-<feature-slug>-review-round-<N>.md` 报告路径。明确授权评审、契约内修复与必要验证；具体评审及证据处置由它负责。

返回需求变化时回 Stage 1；返回 `completed` 且没有阻塞项、接口检查通过后，登记报告及最终内容身份、结论、验证证据和限制。自动完整读取并执行 [整合准备](references/integration-preparation.md)。这是独立编排阶段，不属于 Stage 3。

用户要求执行到 Stage 4 之前时，在整合准备完成后停止，不读取或进入 Stage 4。否则自动读取并执行 [Stage 4 整合与清理](references/stage-4-integration.md)，推进至 merge-ready 后按其规则请求唯一合并授权。

## 机械执行

本 skill 只调度自己拥有的机械工作。初始化连续批次及 Stage 4 Git 写操作由主代理直接执行；其余命令已确定、非交互且失败可原样返回的机械只读批次默认下放，微小检查、槽位被实际工作占满或宿主无法可靠下放时直接执行。首次下放前完整读取 [低成本代理协议](references/low-cost-execution-agent.md)；没有下放不读取，同一主任务已读取相同协议标识时不重复加载。能力内部事件不进入 lifecycle 台账。

临时目标观测、外层集成和交付证据分别按编排契约处理；观测记录缺失不阻塞能力调用、Git 操作或阶段推进。
