# Contributing

## 添加或修改 Skill

1. 将 Skill 放在 `plugins/feature-skills/skills/<skill-name>/`。
2. 保证目录名和 `SKILL.md` 的 `name` 完全一致。
3. 在 `description` 中写清能力、触发场景和必要边界。
4. 只添加当前工作流真实需要的 `agents/`、`scripts/`、`references/` 或 `assets/`。
5. 对新增或修改的脚本执行实际 smoke test。
6. 运行 `./scripts/validate-skills.ps1`。
7. 在 `CHANGELOG.md` 的 `Unreleased` 下记录用户可见变化。

## Skill 设计原则

- 假设 Codex 已具备通用能力，只记录会改变决策或提高可靠性的知识。
- 使用渐进式披露：入口保持紧凑，条件性细节放入引用文件。
- 保留用户授权边界；Skill 不得把普通任务扩展为外部发布、删除、付费或权限变更。
- 自动调用默认开启。只有明确需要显式调用时，才在 `agents/openai.yaml` 中设置 `policy.allow_implicit_invocation: false`。
- 不要加入仅用于占位的文件、空示例或无法验证的通用规则。

## Pull Request 门禁

提交前确认：

- Marketplace 和 Plugin JSON 可以解析。
- Plugin 版本是严格 SemVer。
- 所有 Skill 名称唯一，且与目录一致。
- 没有 `[TODO: ...]` 脚手架占位符。
- 没有密钥、私人数据、内部地址或版权不明确的资产。
- 相关脚本的实际行为已经验证。

CI 会执行仓库校验器，但不会替代对 Skill 触发准确性和真实工作流结果的人工检查。
