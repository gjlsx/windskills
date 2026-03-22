# taskexec 实测流程评估报告

日期：2026-03-23  
评估对象：`skills/taskexec`  
评估视角：AI agent 系统工程 / 实际执行成本 / 规则可维护性 / 追踪闭环

## 1. 结论摘要

这次 `taskexec` 的真实 smoke test 证明了一件事：当前流程可以跑通，而且追踪链路是完整的；但它在“小任务 + 小 bugfix”场景下已经出现明显过度流程。

最值得优先处理的不是“能不能执行”，而是“执行成本是否合理”。这次测试里，`taskexec` 已经能做到：

- 有规则入口
- 有 tasklist
- 有 task log
- 有验证与自审
- 有 commit 追踪

但同时也暴露出 4 个核心问题：

1. `tasklistall.md` 缺少明确的 tasklist 生命周期管理，导致真实跑完后仍然留下多个 `active`。
2. 小范围 follow-up bugfix 目前实际上被迫开了一个新的 tasklist，成本偏高。
3. “提交后必须把 commit hash 立即回写 tasklist” 这个要求，在真实执行中导致了 metadata-only commit。
4. `memorys/global.md`、锁文件、索引维护这些机制对大项目有价值，但对单 agent 小任务场景有些偏重。

一句话判断：

`taskexec` 当前更像“强追踪模式”，还缺少“轻量执行模式”和“同一任务流内 bugfix 复用规则”。

## 2. 本次评估依据的真实产物

本报告不是基于想象流程，而是基于这次仓库里已经真实生成的文件与提交记录：

- `tasklist03230450.md`
- `tasks/tasklog/codex_t03230450.p001.md`
- `tasklist03230500.md`
- `tasks/tasklog/codex_t03230500.p001.md`
- `tasklistall.md`
- `.agent-rules.md`
- `tasklist_rules.md`
- `memorys/global.md`

以及对应的提交链：

- `17195c9` `tasklist03230450 Taskexec workflow smoke test for Python bucket sort`
- `9fdf799` `codex_t03230450.p001`
- `41aecd5` `codex_t03230450.p001 metadata`
- `ac0310c` `tasklist03230500 Bucket sort demo regression fix`
- `6293f17` `codex_t03230500.p001 FIX:t03230500.p001`
- `bcd0b2c` `codex_t03230500.p001 metadata`

## 3. 实际执行流程复盘

## 3.1 第一次 smoke test

第一次 smoke test 的实际链路是：

1. bootstrap 根目录规则与默认目录
2. 创建 `tasklist03230450.md`
3. 将 tasklist 注册进 `tasklistall.md`
4. 提交 tasklist
5. 执行 `t03230450.p001`
6. 写 task log
7. 跑验证
8. 提交任务代码
9. 为了把任务 commit hash 回写到 tasklist，再做一次 metadata-only commit

这一轮的优点是链路完整、可审计；缺点是对一个单文件 smoke test 来说，流程已经偏重。

## 3.2 后续 bugfix

后续用户又改坏了 `test/bucket_sort_demo.py`。在“按 taskexec 处理 bugfix”时，实际发生的是：

1. 原任务 `t03230450.p001` 已经 `done`
2. 当前规则没有明确规定“同一 tasklist 下的小 bugfix 如何复用”
3. 因此实际选择了新建 `tasklist03230500.md`
4. 再创建新的 task `t03230500.p001`
5. 再执行、验证、提交
6. 再做一次 metadata-only commit

也就是说，一个紧贴前一个 smoke test 的回归修复，最终新增了：

- 1 个新 tasklist
- 1 行新的索引记录
- 1 个新的 task log
- 3 个新的 commit

这个结果说明：当前规则在 bugfix 场景下偏向“重新开一条完整工作流”，而不是“在同一工作流里做追踪性补丁”。

## 3.3 从这次实测看到的成本

如果只从真实执行成本看，这次流程的特点很明确：

- 完成 1 个 smoke test + 1 个紧随其后的回归修复，总共产生了 2 个 tasklist
- 总共产生了 2 个 task log
- 总共产生了 6 个 commit
- 其中 2 个 commit 本质上只是 metadata backfill
- `tasklistall.md` 最终留下了 2 个 `active`

这说明当前规则“可追踪性很强”，但“收口成本偏高”。

## 4. 哪些设计是有效的，建议保留

以下设计在这次实测里是有效的，建议保留，不要为了减负把这些核心价值删掉：

### 4.1 规则先读，再执行

先读 `.agent-rules.md`、再读 `tasklist_rules.md`、再读 tasklist，这个顺序是合理的。  
它保证了 executor 不会直接把 tasklist 当成唯一真相，也避免 skill 和项目本地规则打架。

### 4.2 task log 是有价值的

这次两个 `tasks/tasklog/*.md` 都很有用，因为它们真实记录了：

- 输入来源
- 计划
- 改动文件
- 验证命令
- 自审结论

如果只保留 tasklist 而没有 task log，很多执行细节会丢失。

### 4.3 固定 TaskID 和固定 lock 命名是对的

统一成 `tMMDDhhmm.pXXX` 和 `<agent>_<taskid>.lock` 以后，规则理解成本明显下降。  
这一点已经比之前稳定很多，建议不要再摇摆。

### 4.4 验证 + 自审是必要的

这次 bugfix 能形成闭环，很大程度上是因为 task log 里明确记录了验证命令和结果。  
这部分是 `taskexec` 的价值核心，不建议弱化。

## 5. 主要问题与优化建议

下面是按优先级排的分析。

## 5.1 P1：tasklist 生命周期规则不完整

### 现象

当前真实结果里，`tasklistall.md` 同时存在两条 `active`：

- `tasklist03230450.md`
- `tasklist03230500.md`

但实际上，这两份 tasklist 内部的任务都已经完成。

### 问题

这会导致两个系统性后果：

1. index 不再可靠，因为 `active` 不等于“仍在执行”
2. 以后如果用户只说“继续下一个 task”，agent 很难明确应该进入哪一个 tasklist

### 根因

当前规则定义了“task 状态”，但没有真正定义“tasklist 何时从 active 变成 done / archived”。

### 建议

给 tasklist 增加明确生命周期：

- `active`：仍有待执行任务，或仍允许在其下继续追加 follow-up
- `done`：该 tasklist 中当前计划任务全部完成，默认不再继续追加
- `archived`：已经备份到 `docs/backuptask/`

同时要求：

1. 当 tasklist 中所有任务都变成 `done` 且不再追加 follow-up 时，tasklist 状态改为 `done`
2. `tasklistall.md` 对应行也必须同步改为 `done`
3. 真正移入 `docs/backuptask/` 后，索引状态再改为 `archived`

这是当前最应该优先补的规则。

## 5.2 P1：默认没有定义“多个 active tasklist 时怎么选”

### 现象

这次实测后真实存在多个 `active` tasklist。  
当前默认规则更多是在解决“如何找到 tasklist 文件”，但没有完全解决“多个候选时选谁”。

### 问题

如果以后用户没有明确指定 tasklist，而项目里同时存在多个 `active`：

- agent 可能选最新的
- agent 可能选第一个
- agent 也可能误入 backup 中的同名文件

这会造成行为不一致。

### 建议

默认解析规则应明确为：

1. 用户显式指定 tasklist 路径时，直接使用
2. 未指定时，从 `tasklistall.md` 读取所有 `active` 项
3. 若 `active` 只有 1 个，自动使用
4. 若 `active` 超过 1 个，停止自动选择，要求用户指定
5. 若项目想强制“总是使用最新 active”，必须由项目自己的 `.agent-rules.md` 显式声明

结论：  
“找文件”与“选任务流”是两个不同问题，当前 skill 已经解决了前者，但后者还不够明确。

## 5.3 P1：小范围 bugfix 不应默认每次都开新 tasklist

### 现象

这次 bucket sort 回归修复，本质上是紧跟上一条 smoke test 的 follow-up bugfix。  
但由于旧任务已经 `done`，又没有“同 tasklist 内追加 follow-up”的标准规则，最终实际开了一个新 tasklist。

### 问题

这会让小 bugfix 的制度成本过高：

- 额外建 tasklist
- 额外更新 index
- 额外做 tasklist commit
- 额外产生一轮归档与生命周期管理

对于微小回归修复来说，这个成本偏高。

### 我的建议

不要把“bugfix 是否新开 tasklist”做成一刀切。  
应该按场景分层：

#### 场景 A：bug 在当前任务尚未标记 `done` 前发现

建议：  
直接在当前任务里修，不新建 task，不新建 tasklist。

#### 场景 B：原任务已 `done`，但同一 tasklist 仍处于 `active`，且 bugfix 明显属于同一范围

建议：  
在同一个 tasklist 里新增一条新的 bugfix task。  
不要重开 tasklist，但也不要回头修改已经 `done` 的旧 task 行。

这是我认为最合理的默认做法。

#### 场景 C：原 tasklist 已归档，或者 bugfix 已经跨范围、跨版本、跨阶段

建议：  
新开 tasklist。

### 推荐的默认规则

`bugfix` 不应默认“每次都开新 tasklist”。  
推荐默认策略是：

- 优先复用当前 `active` tasklist
- 只新增新的 bugfix task 行
- 只有在原 tasklist 已 `done/archived` 或 scope 已变化时，才新开 tasklist

这条建议是本次评估最重要的流程优化点之一。

## 5.4 P2：Git hash 回写规则导致 metadata-only commit

### 现象

这次 6 个 commit 中，有 2 个是纯 metadata backfill：

- `41aecd5`
- `bcd0b2c`

它们存在的主要原因只有一个：  
任务 commit 产生后，要把该 hash 再写回 tasklist。

### 问题

这会带来几个坏处：

- 提交历史噪音增加
- 一个任务可能固定变成“两次提交”
- 真正有价值的代码提交被 metadata commit 打断

### 建议

这里建议二选一：

#### 方案 1：允许延迟回写

任务完成时，task log 必须记录真实 commit hash；  
tasklist 的 `Git` 字段允许在“下一个自然的 tasklist 维护提交”或“tasklist 收口提交”时统一回写。

优点：

- 不需要 metadata-only commit
- tasklist 仍然能最终补齐

#### 方案 2：工具化自动回写

如果未来提供脚本自动生成 commit、回填 hash、再 amend 或统一维护，则可以保留强一致性。

但以当前 skill 的纯文档工作流来说，这个方案依赖更强，不适合作为默认要求。

### 推荐结论

在没有自动化脚本前，建议采用“允许延迟回写”的规则，避免强制 metadata-only commit。

## 5.5 P2：`memorys/global.md` 对小仓库/小任务过重

### 现象

这次 smoke test 中，`memorys/global.md` 的实际内容非常少，更多是在满足流程要求，而不是提供决策价值。

### 问题

如果所有新仓库都要先建立 global memory，容易出现：

- 文件形式存在，但内容空泛
- 新用户以为必须维护很多 memory
- bootstrap 心理成本上升

### 建议

把 `memorys/global.md` 调整为“默认路径 + 惰性创建”：

- 规则里保留默认路径
- 首次运行时如果没有全局记忆需求，可不创建
- 只有出现项目级长期规则、项目记忆入口或跨任务共享知识时再创建

这样更符合“小仓库先跑起来，再逐步加治理”的节奏。

## 5.6 P2：锁文件对单 agent 本地场景偏重，可考虑分模式

### 现象

这次测试是单 agent、本地执行、无并行抢占场景。  
锁机制理论上没错，但在这种模式下实际保护收益很有限。

### 问题

当前锁规则对多人并发仓库是合理的，但对单人本地 smoke test 来说偏重：

- 要额外扫描目录
- 要额外创建 / 删除 lock
- 还要写进 skill 心智模型

### 建议

增加两种执行模式：

#### Lite 模式

- 单 agent
- 单分支
- 本地即时执行
- 可不落地 lock 文件，只在 tasklist 中用 `doing` 标识占用

#### Full 模式

- 多 agent / 多人协作
- 必须使用实体 lock 文件
- 严格执行抢锁保护

### 推荐结论

锁机制不该删除，但建议从“总是强制”改成“仓库可配置为 full / lite”。

## 5.7 P2：tasklist 状态与索引状态目前是两层重复信息，但缺少同步规则

### 现象

每个 tasklist 内部有 status，`tasklistall.md` 里也有 status。  
这本身没有错，但真实执行后两层状态很容易一起滞后。

### 问题

如果没有同步规则，最终会出现：

- task 已全 done，但 tasklist 仍 active
- tasklist 已结束，但 index 仍 active
- backup 已完成，但索引未反映

### 建议

明确规定“谁是触发源、谁必须同步”：

1. task 状态变化不需要更新 index
2. tasklist 生命周期变化必须同步到 index
3. 归档动作必须同时更新 tasklist 与 index

这样重复信息才不会成为脏状态源。

## 5.8 P3：文档分层基本清晰，但未来还可以继续瘦身

### 现象

经过前面几轮调整后，`tasklist_rules.md` 与 `.agent-rules.md` 的职责已经比之前清楚很多。  
但从工程落地角度看，未来仍可继续压缩重复说明。

### 建议

长期方向建议保持为：

- `SKILL.md`：只讲“什么时候用 + 执行总流程”
- `.agent-rules.md`：只讲仓库级路径、锁、commit、索引解析、模式开关
- `tasklist_rules.md`：只讲 tasklist 结构、字段、状态、评审要求

这个方向已经对了，后续只需要继续减少重复即可。

## 6. 对 bugfix 工作流的明确建议

这是本次评估里最值得单独落地的一条规则。

## 6.1 建议的默认判定矩阵

| 场景 | 建议动作 |
|---|---|
| bug 在当前 task 尚未 `done` 前发现 | 直接在当前 task 内修复 |
| 原 task 已 `done`，但原 tasklist 仍 `active`，且 bugfix 属于同一范围 | 在同一 tasklist 新增 1 条 bugfix task |
| 原 tasklist 已 `done` 或 `archived` | 新开 tasklist |
| bugfix 已明显跨 scope / 跨里程碑 / 跨版本 | 新开 tasklist |

## 6.2 不建议的默认做法

不建议把下面这条设为默认：

`只要是 bugfix，就必须新开一个 tasklist`

原因很简单：  
它对追踪有帮助，但对真实执行成本过高，尤其是紧随主任务的微小回归修复。

## 6.3 更合理的默认策略

我建议把默认策略改成：

`bugfix 默认优先复用当前 active tasklist；只有在 tasklist 已关闭或 scope 已变化时，才新开 tasklist。`

这条规则既保留追踪性，也明显降低制度摩擦。

## 7. 建议的最小修改集合

如果下一步要继续完善 `skills/taskexec`，我建议先做最小而有效的一组修改，而不是一次大改。

### 第一优先级

1. 增加 tasklist 生命周期：`active` / `done` / `archived`
2. 增加多个 `active` tasklist 的默认选择规则
3. 增加 bugfix 复用当前 tasklist 的规则

### 第二优先级

4. 放宽 Git hash 必须立即回写 tasklist 的要求
5. 将 `memorys/global.md` 改为惰性创建
6. 增加 lite / full 两种执行模式

### 第三优先级

7. 补一个“tasklist 收口 / 归档”标准示例
8. 补一个“同 tasklist 下追加 bugfix task”的标准示例

## 8. 我对当前 skill 的总体判断

站在 AI agent 系统工程的角度，当前 `taskexec` 已经具备了一个可执行流程的骨架，而且最大的进步是：

- 规则边界比之前清楚
- TaskID 和 lock 命名已统一
- tasklist 结构也已经收敛到单一真源

但它还没有完全进入“适合高频日常使用”的阶段。  
它当前更适合：

- 对过程追踪要求很高的任务
- 多 agent / 多轮接力的任务
- 需要保留强审计链路的任务

而对下面这些场景，它还偏重：

- 小任务
- 紧随其后的微型 bugfix
- 单人单 agent 本地验证

所以我给它的整体评价是：

`方向正确，骨架成立，但还需要一次“减摩擦优化”。`

## 9. 最终建议

如果只保留一句最重要的工程建议，那就是：

`不要让 taskexec 为了追踪而牺牲过多执行效率。`

具体落地时，最应该优先调整的是这三条：

1. 定义 tasklist 生命周期与收口规则
2. 定义 bugfix 何时复用当前 tasklist、何时新开 tasklist
3. 去掉“为了回填 commit hash 而额外做 metadata-only commit”的隐性强制

只要这三条落地，`taskexec` 的真实使用体验会明显更顺。



修改意見：

task 提交完成某個任務所有文件后，必須在tasklog裏記錄真實commit hash,寫回這次hash到tasklist,并且同時改變了staus狀態后，后只需要再做comit 這個 tasklist 文件本身即可,這個要記錄為規則，并且要在最前面規則寫明，tasklist 的列應該應該加一列 detail，指向默認tasks/details/d_t03230500.001.md / 這裏是d_taskid 這個文檔詳細描述task信息 以免task信息過長在tasklist裏放不下，當然要寫明如果1，2句話就説完了task可以detail爲空。tasklistxxx.md本身每次修改完任務狀態都需要提交commit。 在歸檔到backup文件夾后需要再提交一次，每一次執行歸檔操作應該掃描/目錄下所有tasklist 文件，如果task全部都done了應該都歸檔，并且同時更新tasklistall狀態或者再添加新tasklist時候時候需要同樣掃描一次，或者用戶明確要求提交後再提交，，tasklist增加生命周期 ，允許follow -up    2 ,應該是同一工作流/優先復用當前tasklist裏做追蹤補丁，也就是只要該tasklist還沒有被歸檔就可以在tasklist添加 task,同時在description裏加個FIX:xxx表明是task任務，該task由提出bug 人員交由 tasklist制定人添加， 并且只能由制定人添加，tasklist 在title,task name,desc中要加制定人，就在name 前面吧 變成 codex: taskname 這樣的制定人: +name, 然後由參與者正常認領任務   ,具體動作就用這個：| bug 在当前 task 尚未 done 前发现 | 直接在当前 task 内修复 |
| 原 task 已 done，但原 tasklist 仍 active，且 bugfix 属于同一范围 | 在同一 tasklist 新增 1 条 bugfix task |
| 原 tasklist 已 done 或 archived | 新开 tasklist |
| bugfix 已明显跨 scope / 跨里程碑 / 跨版本 | 新开 tasklist  ，


在新建tasklist 後者吧自己tasklist添加到tasklistall后，或者歸檔某個taskilist到歸檔目錄后，后 ，需要讀tasklistall, 根據其中active的tasklist文檔掃描根目錄和tasklist配置目錄的實際tasklist文件，如果其中task全部done了就歸檔，并且改變tasklistall,裏的幾個tasklist active為e或者archive,然後需要commit tasklistall

detail路徑就是 tasks/details/ ,agent執行中生成的tasks/codex/t03230450.p001.md,統一放到tasks/tasklog/裏 ，tasks/tasklog/codex_t03230450.p001.md  ，這
