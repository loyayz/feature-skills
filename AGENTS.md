# Repository Instructions

## Skill 更新与本机同步

每次新增、修改、重命名或删除 `plugins/feature-skills/skills/` 下的 Skill 后，都必须在本次任务结束前同步更新本机安装，不能只修改仓库源码。

1. 在仓库根目录运行校验：

   ```powershell
   ./scripts/validate-skills.ps1
   ```

2. 通过本仓库已注册的本地 Marketplace 重新安装 Plugin：

   ```powershell
   codex plugin add feature-skills@loyayz-feature-skills
   ```

   如果本机尚未注册该 Marketplace，先在仓库根目录执行一次：

   ```powershell
   codex plugin marketplace add .
   ```

3. 使用 `codex plugin list` 确认 `feature-skills@loyayz-feature-skills` 为 `installed, enabled`，并确认本次涉及的 Skill 已出现在插件缓存中。

4. 告知用户需要新建 Codex 任务测试更新后的 Skill；现有任务的 Skill catalog 不会热更新。

不要把这些 Skill 直接复制到 `~/.agents/skills/`。本机同步以本地 Marketplace 安装的 Plugin 为唯一来源，避免同名 Skill 重复或来源不一致。不要仅为刷新本机缓存而提升正式版本号。
