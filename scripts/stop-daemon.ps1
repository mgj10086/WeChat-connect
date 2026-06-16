<#
.SYNOPSIS
  停止 WeChat Claude Code 守护进程
#>

$daemonProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "main\.js" }

if ($daemonProcess) {
    Write-Host "找到守护进程 (PID: $($daemonProcess.Id))，正在停止..." -ForegroundColor Yellow
    $daemonProcess | Stop-Process -Force
    Write-Host "✅ 守护进程已停止" -ForegroundColor Green
}
else {
    Write-Host "ℹ️  未找到运行中的守护进程" -ForegroundColor Gray
}
