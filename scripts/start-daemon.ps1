<#
.SYNOPSIS
  启动 WeChat Claude Code 守护进程（新窗口）
#>

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$SrcDir = Join-Path $ProjectRoot "src"
$DataDir = Join-Path $ProjectRoot "data"

# 确保数据目录存在
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

Write-Host "启动 WeChat Claude Code 守护进程..." -ForegroundColor Cyan
Write-Host "将在新窗口中运行。关闭窗口即停止。" -ForegroundColor Gray
Write-Host ""

# 在新窗口中启动 daemon，继承当前环境变量
Start-Process powershell -ArgumentList @"
-NoExit -Command `"cd '$SrcDir'; `$env:DATA_DIR='$DataDir'; node dist/main.js`"
"@

Write-Host "✅ 守护进程已启动（新窗口）" -ForegroundColor Green
Write-Host ""
Write-Host "提示："
Write-Host "  - 保持窗口打开，关闭即停止"
Write-Host "  - 用 status.ps1 检查运行状态"
Write-Host "  - 用 stop-daemon.ps1 停止"
