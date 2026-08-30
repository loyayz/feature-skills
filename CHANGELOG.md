# Changelog

本文件记录 `feature-skills` 的版本变化。版本遵循 [Semantic Versioning](https://semver.org/)。

## [Unreleased]

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

[Unreleased]: https://github.com/loyayz/feature-skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/loyayz/feature-skills/releases/tag/v0.1.0
