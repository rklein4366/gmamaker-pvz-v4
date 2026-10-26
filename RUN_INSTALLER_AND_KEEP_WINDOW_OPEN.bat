@echo off
setlocal
title PvZ Zomboss Low-Health and Death Fix V5.1

echo.
echo ============================================================
echo PvZ Zomboss low-health smoke, pulse and death fix V5.1
echo ============================================================
echo.
echo Paste the full path to the project folder containing PvZ.yyp.
echo Do not paste the PvZ.yyp filename itself. Spaces in the path are okay.
echo.
set /p "PVZ_PROJECT_ROOT=Project folder: "
if not defined PVZ_PROJECT_ROOT (
    echo.
    echo ERROR: No project folder was entered.
    pause
    exit /b 1
)
set "PVZ_PATCH_DIR=%~dp0"
set "PVZ_LOG=%USERPROFILE%\Desktop\pvz_boss_low_health_death_v5_1_log.txt"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $log=$env:PVZ_LOG; if (-not (Test-Path -LiteralPath (Split-Path -Parent $log))) { $log=Join-Path $env:TEMP 'pvz_boss_low_health_death_v5_1_log.txt'; $env:PVZ_LOG=$log }; $project=$env:PVZ_PROJECT_ROOT.Trim().Trim([char]34); try { Start-Transcript -Path $log -Force | Out-Null; Write-Host ('Project folder: ' + $project); Write-Host ('Log file: ' + $log); Write-Host ''; & (Join-Path $env:PVZ_PATCH_DIR 'Apply_Boss_Low_Health_Death_Fix.ps1') -ProjectRoot $project; Write-Host ''; Write-Host 'INSTALLER FINISHED. Check the messages above before opening GameMaker.' -ForegroundColor Green } catch { Write-Host ''; Write-Host 'INSTALLER FAILED. The specific error is shown below and saved in the log.' -ForegroundColor Red; Write-Host ($_ | Out-String) -ForegroundColor Red } finally { try { Stop-Transcript | Out-Null } catch {} }; Write-Host ''; Write-Host ('Log file: ' + $env:PVZ_LOG); Read-Host 'Press Enter to close this window'"
endlocal
