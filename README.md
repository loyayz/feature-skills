# Feature Skills

集中维护并通过 GitHub 分发的 Codex Skills 集合。本仓库同时是 Skill 源码仓库、Codex Plugin 和可安装的 Plugin Marketplace。

## 快速安装

安装 Marketplace：

```
codex plugin marketplace add loyayz/feature-skills --ref master
```

安装其中的 Plugin：

```
codex plugin add feature-skills@loyayz-feature-skills
```

安装后请新建一个 Codex 任务，让新 Skill 在干净的上下文中加载。可以通过 `$skill-name` 显式调用，也可以由 Codex 根据 `SKILL.md` 中的 `description` 自动选择。

## Skills

| Skill | 用途 | 调用方式 |
|---|---|---|
| `feature-lifecycle` | 显式启动最终 Spec、开发、评审、整合与清理的全生命周期流程。 | 仅显式 `$feature-lifecycle` |
| `feature-spec` | 显式收敛需求、完成第一原理设计并形成唯一最终 Spec。 | 仅显式 `$feature-spec` |
| `feature-dev` | 显式依据已固化的实施就绪 Spec 自主选择执行方式并完成实现与受影响验证。 | 仅显式 `$feature-dev` |
| `feature-review` | 显式执行双轴评审，并按授权完成缺陷修复和验证。 | 仅显式 `$feature-review` |

## 更新

先刷新 GitHub Marketplace，再重新安装 Plugin：

```
codex plugin marketplace upgrade loyayz-feature-skills
codex plugin add feature-skills@loyayz-feature-skills
```

需要可复现安装时，将 `--ref master` 替换为已经发布的 Git tag，例如 `--ref v0.1.0`。

## 仓库结构

```text
.agents/plugins/marketplace.json          Marketplace 入口
plugins/feature-skills/
  .codex-plugin/plugin.json               Plugin 清单和版本
  skills/<skill-name>/SKILL.md             Skill 入口
scripts/validate-skills.ps1               本地与 CI 共用的校验器
.github/workflows/validate.yml            GitHub Actions 门禁
```

每个 Skill 可以按实际需要包含：

```text
<skill-name>/
├─ SKILL.md
├─ agents/openai.yaml
├─ scripts/
├─ references/
└─ assets/
```

`SKILL.md` 是唯一必需文件。避免创建没有实际用途的空目录。

## 添加 Skill

在 `plugins/feature-skills/skills/` 下创建一个小写 kebab-case 目录，目录名与 `SKILL.md` 的 `name` 保持一致：

```yaml
---
name: example-skill
description: 说明该 Skill 做什么，以及哪些请求应该触发它。
---

# Example Skill

写下 Codex 执行该工作流所需的非显然规则和步骤。
```

约束：

- 名称只能包含小写字母、数字和连字符，最长 64 个字符。
- 一个 Skill 只负责一类清晰工作。
- `description` 必须准确描述触发条件，避免宽泛的兜底描述。
- 大段条件性资料放进 `references/`，可重复的确定性操作放进 `scripts/`。
- 不要提交密钥、内部接口、私人日志、机器绝对路径或无再分发权限的素材。

详细贡献规则见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 本地验证

在仓库根目录运行：

```powershell
./scripts/validate-skills.ps1
```

校验器会检查 Marketplace、Plugin 清单、语义化版本、引用路径，以及所有 Skill 的名称、frontmatter、重复名称和脚手架占位符。GitHub Actions 对 push 和 pull request 执行相同命令。

## 本地试装

在尚未配置同名远程 Marketplace 的开发环境中：

```powershell
codex plugin marketplace add .
codex plugin add feature-skills@loyayz-feature-skills
```

修改 Skill 后重新运行校验和 `codex plugin add`，然后新建 Codex 任务测试触发行为。

## 发布版本

1. 运行 `./scripts/validate-skills.ps1`。
2. 更新 `plugins/feature-skills/.codex-plugin/plugin.json` 中的 SemVer 版本。
3. 将本次用户可见变化从 `CHANGELOG.md` 的 `Unreleased` 移入对应版本。
4. 提交并推送 `master`。
5. 创建与 Plugin 版本一致的 Git tag，例如 `v0.1.0`，并发布 GitHub Release。

## License

[MIT](LICENSE)
