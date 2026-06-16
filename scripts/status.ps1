<#
.SYNOPSIS
  检查 WeChat Claude Code 守护进程状态
#>

$daemonProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "main\.js" }

if ($daemonProcess) {
    Write-Host "✅ 守护进程运行中" -ForegroundColor Green
    Write-Host "  PID:      $($daemonProcess.Id)" -ForegroundColor Gray
    Write-Host "  启动时间: $($daemonProcess.StartTime)" -ForegroundColor Gray
    Write-Host "  CPU:      $([math]::Round($daemonProcess.CPU, 1))s" -ForegroundColor Gray
    Write-Host "  内存:     $([math]::Round($daemonProcess.WorkingSet64 / 1MB, 1)) MB" -ForegroundColor Gray

    # 检查 data 目录
    $dataDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) "data"
    $accountFile = Join-Path $dataDir "account.json"
    if (Test-Path $accountFile) {
        Write-Host "  微信账号: 已绑定" -ForegroundColor Green
    }
    else {
        # 检查默认路径
        $defaultAccount = Join-Path $env:USERPROFILE ".wechat-claude-code" "accounts"
        if (Test-Path $defaultAccount) {
            Write-Host "  微信账号: 已绑定" -ForegroundColor Green
        }
        else {
            Write-Host "  ⚠️  微信账号: 未绑定（请运行 setup.ps1）" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "❌ 守护进程未运行" -ForegroundColor Red
    Write-Host ""
    Write-Host "启动方法：" -ForegroundColor Gray
    Write-Host "  .\scripts\start-daemon.ps1" -ForegroundColor White
}
