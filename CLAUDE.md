# CLAUDE.md — WeChat Claude Code 项目

## 项目定位

通过微信远程操控 Claude Code。Node.js 守护进程在 Windows 原生运行，调用 `claude` CLI 进程完成 AI 推理（DeepSeek 兼容 API）。

## 架构

```
daemon (Node.js) → spawn claude CLI → DeepSeek API via ANTHROPIC_BASE_URL
```

## 目录结构

| 路径 | 说明 |
|------|------|
| `src/` | wechat-claude-code 源码（git submodule） |
| `scripts/setup.ps1` | 一键初始化 |
| `scripts/start-daemon.ps1` | 启动守护进程 |
| `scripts/stop-daemon.ps1` | 停止 |
| `scripts/status.ps1` | 查看状态 |
| `config/config.json` | 模型、工作目录配置 |
| `docs/` | 运维文档 |

## 命令速查

```powershell
# 安装依赖
cd src && npm install

# 扫码登录
node src/dist/main.js setup

# 启动守护进程
.\scripts\start-daemon.ps1

# 查看状态
.\scripts\status.ps1

# 停止
.\scripts\stop-daemon.ps1
```

## 关键配置

daemon 配置在 `~/.wechat-claude-code/config.json`，模型为 `deepseek-v4-flash[1m]`。

环境变量由 VS Code settings.json 自动注入：
- `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`
- `ANTHROPIC_AUTH_TOKEN=sk-xxx`

## 安全规则

1. 不要在 `auto` 权限模式下运行
2. daemon 不暴露网络端口，仅在本地 spawn 进程
3. `data/` 目录已 .gitignore，不会提交凭证
