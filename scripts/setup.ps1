<#
.SYNOPSIS
  WeChat Claude Code — Windows 初始化脚本
.DESCRIPTION
  1. 安装 Node.js 依赖
  2. 配置 daemon 设置（工作目录、模型）
  3. 扫码绑定微信账号
#>

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$SrcDir = Join-Path $ProjectRoot "src"
$ConfigDir = Join-Path $ProjectRoot "config"
$DataDir = Join-Path $ProjectRoot "data"

Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   WeChat Claude Code 初始化               ║" -ForegroundColor Cyan
Write-Host "║   通过微信远程操控你的 Claude Code         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ----- 1. 检查 Node.js -----
Write-Host "[1/4] 检查环境..." -ForegroundColor Yellow
try {
    $nodeVer = node --version
    $npmVer = npm --version
    Write-Host "  ✅ Node.js $nodeVer" -ForegroundColor Green
    Write-Host "  ✅ npm $npmVer" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ Node.js 未安装或不在 PATH" -ForegroundColor Red
    Write-Host "  请安装 Node.js >= 18: https://nodejs.org/"
    exit 1
}

# ----- 2. 检查 claude CLI -----
try {
    $claudeVer = claude --version 2>$null
    Write-Host "  ✅ Claude Code CLI: $claudeVer" -ForegroundColor Green
}
catch {
    Write-Host "  ⚠️  claude CLI 未找到，确保 Claude Code VS Code 扩展已安装" -ForegroundColor Yellow
}

# 检查关键环境变量
if ($env:ANTHROPIC_BASE_URL) {
    Write-Host "  ✅ ANTHROPIC_BASE_URL = $($env:ANTHROPIC_BASE_URL)" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  ANTHROPIC_BASE_URL 未设置，将使用默认 Anthropic API" -ForegroundColor Yellow
}

# ----- 3. 安装依赖 -----
Write-Host ""
Write-Host "[2/4] 安装 Node.js 依赖..." -ForegroundColor Yellow
Push-Location $SrcDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ npm install 失败" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  ✅ 依赖安装完成" -ForegroundColor Green
Pop-Location

# ----- 4. 配置 daemon -----
Write-Host ""
Write-Host "[3/4] 配置 daemon..." -ForegroundColor Yellow

$ConfigFile = Join-Path $ConfigDir "config.json"
if (Test-Path $ConfigFile) {
    Write-Host "  ✅ 配置文件已存在: $ConfigFile" -ForegroundColor Green
}
else {
    Write-Host "  ℹ️  创建默认配置..." -ForegroundColor Gray
}

# daemon 的配置存储在 ~/.wechat-claude-code/config.json
# 但我们不在这里写，setup 时会自动引导用户配置

# ----- 5. 扫码登录 -----
Write-Host ""
Write-Host "[4/4] 扫码登录..." -ForegroundColor Yellow
Write-Host "  将打开二维码图片，请用微信扫描" -ForegroundColor Gray
Write-Host ""

Push-Location $SrcDir
node dist/main.js setup
$result = $LASTEXITCODE
Pop-Location

if ($result -eq 0) {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   初始化完成！                               ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下一步："
    Write-Host "  启动 daemon：.\scripts\start-daemon.ps1"
    Write-Host "  停止 daemon：.\scripts\stop-daemon.ps1"
    Write-Host "  查看状态：  .\scripts\status.ps1"
}
else {
    Write-Host "  ⚠️  扫码未完成或出错了" -ForegroundColor Yellow
    Write-Host "  可以稍后重新运行：node src/dist/main.js setup"
}
