@echo off
setlocal
cd /d "%~dp0"

echo.
echo Windows 10 Data/AI Setup Kit
echo.
echo This launcher keeps the window open so errors are visible.
echo.

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator permission...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Running as Administrator.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-WindowsDataLab.ps1" -PullSmallLlama
set "EXITCODE=%errorlevel%"

echo.
echo Installer finished with exit code %EXITCODE%.
echo Check the logs folder on this USB for details.
echo.
pause
exit /b %EXITCODE%
