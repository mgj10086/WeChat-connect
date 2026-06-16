# 本地对上游源码的修改

> 记录对 wechat-claude-code (src/) 的本地修改，方便升级子模块后重新应用。

## 修改 1：Windows spawn 兼容

**文件**：`src/src/claude/provider.ts`

**原因**：Windows 上 npm 全局安装的 CLI 以 `.cmd` 文件形式存在，Node.js 的 `child_process.spawn('claude')` 找不到。需要：
1. 使用 `claude.cmd` 而非 `claude`
2. 设置 `shell: true` 以确保 `.cmd` 文件被正确执行

**改动**：

```diff
+ // Windows needs the .cmd extension for npm-installed global CLIs
+ const CLAUDE_BIN = process.platform === 'win32' ? 'claude.cmd' : 'claude';
```

```diff
- child = spawn('claude', args, {
+ child = spawn(CLAUDE_BIN, args, {
     cwd,
     stdio: ['pipe', 'pipe', 'pipe'],
     env: { ...process.env },
+    shell: process.platform === 'win32',
   });
```

**升级后重新应用**：
```bash
cd src
git pull origin main
# 手动将上述 diff 应用到 src/src/claude/provider.ts
npm run build
```

## 修改 2：系统提示词

**位置**：`~/.wechat-claude-code/config.json`（非源码，不随升级丢失）
**内容**：添加了 `systemPrompt` 字段，让回复更简洁、适合微信聊天。

## 未修改的配置

所有 daemon 配置通过 `~/.wechat-claude-code/config.json` 管理，不受子模块升级影响：
- 模型：`deepseek-v4-flash[1m]`
- 工作目录：`d:\works\AIclass\agent\WeChat_claude`
- 系统提示词：精简回复风格
