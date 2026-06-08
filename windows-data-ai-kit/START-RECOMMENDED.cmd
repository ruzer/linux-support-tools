@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator permission...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-WindowsDataLab.ps1" -NoMenu -PullSmallLlama -InstallAcademicOpenSource -InstallLocalAIApps
set "EXITCODE=%errorlevel%"
echo.
echo Installer finished with exit code %EXITCODE%.
pause
exit /b %EXITCODE%

