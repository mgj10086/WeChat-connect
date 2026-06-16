# WeChat-connect

企业微信 + 个人微信双通道 Claude Code 桥接器。

## 双通道架构

```
┌─ 企业微信 朏朏 ─────────────────────────┐
│  cc-connect → claude.exe → DeepSeek API  │  ← 群聊可见、名字可自定义
└──────────────────────────────────────────┘

┌─ 个人微信 ClawBot ──────────────────────┐
│  wechat-claude-code → claude.exe → DeepSeek │  ← 自己用
└──────────────────────────────────────────┘
```

## 快速开始

### 前置条件
- Windows 11 + Node.js >= 18
- 微信已登录
- 企业微信管理后台权限（可选）
- claude CLI 已安装（VS Code 扩展自带）

### 个人微信通道

```bash
cd src
npm install
npm run setup     # 显示二维码 → 微信扫码
npm run start     # 启动守护进程
```

### 企业微信通道

1. 企业微信后台 → 应用管理 → 智能机器人 → 创建「朏朏」
2. 获取 BotID + Secret

```bash
set WECOM_BOT_ID=xxx
set WECOM_BOT_SECRET=xxx
node src/dist/main.js
```

## 源码补丁

`patches/` 目录包含对上游 wechat-claude-code 的修改：
- **provider.ts**: Windows `claude.exe` 直接调用（绕过 cmd.exe 字符限制）
- **wecom-bot.ts**: 企业微信智能机器人 WebSocket 通道（基于官方 SDK）
- **memory.ts**: 文件级持久记忆系统

## 项目结构

```
├── src/              ← 上游 wechat-claude-code（需自行 git clone）
├── patches/          ← 我们的补丁文件
├── config/           ← 运行配置
├── scripts/          ← PowerShell 管理脚本
├── docs/             ← 文档
└── data/             ← 持久化数据
```
