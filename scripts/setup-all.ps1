<#
.SYNOPSIS
  WeChat-connect 一键安装脚本
  克隆 wechat-claude-code 源码 + 应用补丁（Windows 兼容 + 企业微信通道 + 持久记忆）
#>

$ProjectRoot = Split-Path -Parent $PSCommandPath
$SrcDir = Join-Path $ProjectRoot "src"

Write-Host "=== WeChat-connect 安装 ===" -ForegroundColor Cyan

# 1. 克隆源码
if (Test-Path $SrcDir) {
  Write-Host "src/ 已存在，跳过克隆" -ForegroundColor Yellow
} else {
  Write-Host "正在克隆 wechat-claude-code..." -ForegroundColor Gray
  git clone https://ghproxy.net/https://github.com/Wechat-ggGitHub/wechat-claude-code.git $SrcDir
}

# 2. 安装依赖
Write-Host "正在安装依赖..." -ForegroundColor Gray
cd $SrcDir
npm install
npm install ws @wecom/aibot-node-sdk

# 3. 应用补丁
Write-Host "正在应用补丁..." -ForegroundColor Gray

# provider.ts - Windows claude.exe 兼容
$provider = Get-Content "src/claude/provider.ts" -Raw
$provider = $provider -replace "import { logger } from '../logger.js';", "import { logger } from '../logger.js';`n`nconst CLAUDE_BIN = process.platform === 'win32'`n  ? (process.env.CLAUDE_EXE_PATH || 'C:/Users/Administrator/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/bin/claude.exe')`n  : 'claude';"
$provider = $provider -replace "child = spawn\('claude', args, {", "child = spawn(CLAUDE_BIN, args, {`n        shell: process.platform === 'win32',"
Set-Content "src/claude/provider.ts" -Value $provider

# wecom-bot.ts + memory.ts 已在仓库中
# 只需复制到 src/
Copy-Item (Join-Path $ProjectRoot "patches/wecom-bot.ts") (Join-Path $SrcDir "src/wecom-bot.ts") -Force
Copy-Item (Join-Path $ProjectRoot "patches/memory.ts") (Join-Path $SrcDir "src/memory.ts") -Force

# main.ts 补丁
$mainContent = Get-Content "src/main.ts" -Raw
$mainContent = $mainContent -replace "import { buildMemoryContext, initMemoryFiles } from './memory.js';", "import { buildMemoryContext, initMemoryFiles } from './memory.js';`nimport { WeComBot, type BridgeMessage } from './wecom-bot.js';"
# 添加企业微信启动
$mainContent = $mainContent -replace "logger.info\('Daemon started'.+", "`$0`n`n  const wecomBotId = process.env.WECOM_BOT_ID;`n  const wecomSecret = process.env.WECOM_BOT_SECRET;`n  if (wecomBotId && wecomSecret) {`n    startWeComChannel(config, session, sessionStore, wecomBotId, wecomSecret);`n  }"
Set-Content "src/main.ts" -Value $mainContent

# 追加企业微信处理函数
Add-Content "src/main.ts" @"

// --- WeCom channel ---
function startWeComChannel(config, session, sessionStore, botId, secret) {
  const bot = new WeComBot({ botId, secret }, {
    onMessage: async (msg) => {
      logger.info('wecom msg', { userId: msg.userId, text: msg.text.slice(0, 100) });
      await processWeComMessage(msg, config, session, sessionStore, bot);
    },
  });
  bot.connect();
  logger.info('WeCom bot started', { botId });
}
// ... processWeComMessage ...
"@

# 4. 编译
Write-Host "正在编译..." -ForegroundColor Gray
npx tsc

Write-Host "=== 安装完成 ===" -ForegroundColor Green
Write-Host "1. 配置企业微信凭据："
Write-Host "   set WECOM_BOT_ID=xxx"
Write-Host "   set WECOM_BOT_SECRET=xxx"
Write-Host "2. 运行：node dist/main.js"
