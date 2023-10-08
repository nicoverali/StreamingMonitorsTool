@echo off

:: Check if script is running with admin privileges and elevate if needed
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set objShell = CreateObject("Shell.Application") > "%temp%\getadmin.vbs"
    echo objShell.ShellExecute "%~0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /b

:gotAdmin
    :: Execute the PowerShell downloader script
    powershell -ExecutionPolicy Bypass -File "%~dp0tool-downloader.ps1"

    :: If the downloader script fails, exit the batch script
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

    :: If downloader is successful, run the installer script
    powershell -ExecutionPolicy Bypass -File "%~dp0installer.ps1"

    :: If the installer script fails, exit the batch script
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

    :: Continue the rest of the batch script if both scripts are successful
    pause