# WeChat Claude Code

通过微信远程操控你的 Claude Code——手机上发消息，电脑上干活。

## 架构

```
微信 (手机) → 腾讯 iLink API → Node.js 守护进程 → spawn claude CLI → DeepSeek API
                                 Windows 原生             继承环境变量
                                                         ANTHROPIC_BASE_URL
                                                         ANTHROPIC_AUTH_TOKEN
```

**关键认知**：daemon 通过 `spawn('claude', args)` 调用本机 `claude` CLI 进程，所有环境变量和 API 配置由 VS Code 扩展自动注入。**不需要 Anthropic API Key**，你现有的 DeepSeek 配置直接可用。

## 环境

| 项目 | 值 |
|------|-----|
| 操作系统 | Windows 11 |
| Node.js | >= 18 |
| claude CLI | `v2.1.169`（全局 npm 安装） |
| 模型 | `deepseek-v4-flash[1m]`（DeepSeek 兼容 Anthropic API） |
| API 端点 | `https://api.deepseek.com/anthropic` |

## 快速开始

```powershell
# 1. 安装 Node.js 依赖
cd src
npm install
cd ..

# 2. 扫码绑定微信
node src/dist/main.js setup
# 打开二维码图片 → 微信扫码

# 3. 启动守护进程
.\scripts\start-daemon.ps1

# 4. 查看状态
.\scripts\status.ps1
```

## 脚本

| 脚本 | 功能 |
|------|------|
| `scripts/setup.ps1` | 一键初始化（环境检查 + npm install + 扫码） |
| `scripts/start-daemon.ps1` | 在新窗口启动守护进程 |
| `scripts/stop-daemon.ps1` | 停止守护进程 |
| `scripts/status.ps1` | 查看运行状态和资源占用 |

## 在微信中使用

扫码绑定后，你的微信会出现 ClawBot 对话窗口：

| 操作 | 方法 |
|------|------|
| 发送任务 | 在聊天窗口输入文字 |
| 发送图片 | 发送照片/截图，Claude 自动分析 |
| 审批操作 | 回复 `y` 批准 / `n` 拒绝 |
| 中断 | 新消息即可中断当前任务 |
| 查看进度 | 实时看到工具调用（🔧📖🔍）和思考过程（💭） |

### 斜杠命令

`/help` `/clear` `/reset` `/model` `/status` `/cwd` `/skills` 等。

## 配置文件

daemon 配置文件位置：`~/.wechat-claude-code/config.json`

```json
{
  "workingDirectory": "d:\\works\\AIclass\\agent\\WeChat_claude",
  "model": "deepseek-v4-flash[1m]"
}
```

首次运行 setup 时会引导配置。

## 数据存储

```
~/.wechat-claude-code/
├── accounts/       # 微信账号凭证
├── sessions/       # 会话数据
└── config.json     # 运行配置
```

## 安全

- 权限模式建议 `acceptEdits`（自动批准编辑，其他操作需微信审批）
- 不要在 `auto` 模式下运行（Claude 可执行任何命令）
- 守护进程只在本地监听，不暴露端口

## 参考

- [wechat-claude-code](https://github.com/Wechat-ggGitHub/wechat-claude-code) — 上游项目
- [[收件箱/微信接入Claude Code完整指南]] — 接入技术详解
