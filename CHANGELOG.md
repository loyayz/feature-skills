# Changelog

本文件记录 `feature-skills` 的版本变化。版本遵循 [Semantic Versioning](https://semver.org/)。

## [Unreleased]

## [0.2.0] - 2026-09-28

### 新增

- `feature-simple`：显式启动逐项交付流程。使用已有 Spec；未提供时在第一项需求确定后创建。每项需求沿用 `feature-spec` 的四步讨论流程，更新同一份 Spec，再由 `feature-dev` 实现并提交；完成后等待下一项需求。

### 优化

- `feature-lifecycle`：简化 Stage 4 整合流程，仅在 rebase 冲突后加载恢复说明；无冲突时继续整合并复用仍有效的评审与验证证据。
- `feature-spec`：依次展示需求理解、需求决策、方案设计和方案复核四步。根据已确认需求和事实自主处理能够可靠推断的业务选择，只有无法可靠推断且会改变业务结果时才请用户决定；不增加整份 Spec 的审批环节。
- `feature-spec`：最终 Spec 从使用者视角说明问题与预期结果，记录当前有效的规则和必要生产决策；方案设计与复核清理已被取代的方案和历史规则。
- `feature-spec`：默认文档路径调整为 `docs/specs/YY-MM/YYYY-MM-dd-<topic>.md`；编排调用仍使用明确传入的路径。
- `feature-dev`：实现稳定后自检代码可读性、职责与事实归属及多余结构，修正本轮范围内的问题再验证和提交；用户未明确要求执行测试时默认不运行测试，并如实报告验证范围。
- `feature-review`：实现评审核对代码可读性与职责归属；双轴结论分别呈现，规范类问题指明具体规则。有候选问题时才加载裁决说明，确认问题且修复获授权时才加载修复与复审说明；只读评审保留证据核实和验证判断。
- `feature-review`：取消无 finding 后固定追加的定向复核。修复后检查改动及受影响链路，复用仍有效的评审结论；无法界定影响范围或原有整体判断失效时再完整评审。保留一次独立 reviewer、修复与复核轮次上限及失败升级规则。
- 精简原有四个 Skill 的 description，保留显式调用条件和职责边界，减少 catalog 上下文占用。

### 修复

- `feature-lifecycle`：合并成功后、清理过程文件前更新完成状态及最终 Spec 的原仓库路径，避免状态更新落在清理之后。

## [0.1.0] - 2026-09-11

`feature-skills` 首次公开发布。本版本提供一套功能交付 Skills，可分别使用，也可通过完整生命周期统一编排。

### 说明

- `feature-lifecycle`：在隔离工作环境中串联需求规格、开发、评审、整合和清理，形成完整交付流程。
- `feature-spec`：收敛需求、识别真实决策点，并产出实施就绪的唯一最终 Spec。
- `feature-dev`：依据最终 Spec 完成实现，选择与变更范围匹配的执行方式并提供验证证据。
- `feature-review`：从需求符合性和代码质量两个维度评审变更，并在授权范围内修复和复验。

### 工作流特性

- 四个 Skill 均采用显式调用，避免普通开发请求意外进入完整交付流程。
- `feature-lifecycle` 负责阶段编排，三个能力 Skill 保持职责独立，也可以单独调用。
- 流程在没有业务决策、授权缺口、阻塞或明确停止边界时自动推进，只在真正需要用户决定时暂停。
- Spec、实现和评审之间传递结构化验证证据；相同范围且仍然有效的成功结果可以复用，避免机械重复验证。
- 生命周期在隔离工作区中完成变更，在精确的 merge-ready 状态仅请求一次合并授权，并在成功后清理流程资产。

### 分发与质量保障

- 提供 GitHub-backed `loyayz-feature-skills` Marketplace 和可安装的 `feature-skills` Plugin。
- 提供本地与 GitHub Actions 共用的校验器，检查 Marketplace、Plugin 清单、版本、Skill 元数据及引用路径。
- 提供安装、更新、贡献和版本发布文档。

### 使用提示

- 安装或更新 Plugin 后需要新建任务，现有任务不会热更新 Skill catalog。
- 安装方法、Skill 调用方式和本地验证命令见 [README.md](README.md)。

[Unreleased]: https://github.com/loyayz/feature-skills/compare/0.2.0...HEAD
[0.2.0]: https://github.com/loyayz/feature-skills/releases/tag/0.2.0
[0.1.0]: https://github.com/loyayz/feature-skills/releases/tag/0.1.0
