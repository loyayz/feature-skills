---
name: feature-simple
description: Iterate requirements through feature-spec and feature-dev against one persistent Spec, committing each completed change. Use only on explicit user request for feature-simple.
---

# Feature Simple

## 启动与边界

仅当用户明确要求使用 `feature-simple` 或输入 `$feature-simple` 时启动。已启动的当前任务可在每次提交后接收下一项需求，继续同一流程；普通实现请求、其他 Skill 的推荐或过去任务中的调用都不构成新流程启动授权。

本 skill 只编排逐项需求、同一份 Spec 的更新、`feature-dev` 实现及提交，不接管两个能力的需求收敛、技术实现或验证判断。启动时从当前 catalog 确认 `feature-spec` 和 `feature-dev` 可用，优先使用相同命名空间的实际标识；不可用时报告并停止。只在实际调用对应能力时读取其入口与必要 reference，不预加载下一个能力。

在当前 Git 仓库与分支上工作。记录用户提供的 Spec 路径；没有提供时等待用户描述第一项需求，再按 `feature-spec` 的默认路径规则确定输出路径并显式传入，不预先创建空文档。首次确定路径后，后续所有需求都更新同一文件，不另建按需求分割的 Spec。提交需要 Spec 位于当前仓库；提供的路径位于仓库外时先解决仓库内交付路径，不擅自复制或改写原文件。保留工作区已有的无关改动。

## 每项需求

1. 接收用户当前需求，连同现有 Spec、适用项目指令和已知事实显式交给 `feature-spec`。它严格按原有四步流程讨论并逐步向用户展示 checkpoint，自主处理可由事实推断的决策，只把无法可靠推断的业务决定交给用户，形成实施就绪方案并更新指定的同一份 Spec；本 skill 不替它调查、决定、加设整体审批或重写业务语义。首次需求形成第一版，后续需求在现有内容上增改当前有效规则，保留仍成立的既有约定。
2. 仅在 `feature-spec` 返回 `implementation-ready`、实际路径和内容身份可核对后进入开发。仍需业务决定或授权、依赖阻塞时停留在当前需求，不调用开发能力。
3. 将已固化的 Spec、实际文档路径、本轮相对既有 Spec 的需求变化、受保护行为和项目指令交给 `feature-dev`。它只实现本轮新增或改变的责任，执行适用验证，并将本轮 Spec 更新与实现一同 `git commit`。本 skill 核对返回的 `completed`、提交 SHA、提交路径及 Spec 内容身份；缺失或矛盾时把具体缺口退回对应能力，不把未提交的工作当作完成。
4. 提交完成后报告本轮结果、提交和验证限制，再请用户描述下一项需求并等待。下一项需求继续使用相同 Spec 路径；用户结束流程时停止，不自行发明后续需求。

开发发现需求变化时回到本轮 `feature-spec`，按它原有的变化与失效规则更新同一份文档，再继续开发；执行失败或权限缺口保留当前文档、代码和证据，等待所需条件，不跳到下一项需求。每轮只因真实业务决定、授权缺口或执行阻塞暂停，不逐项请求例行技术确认。
