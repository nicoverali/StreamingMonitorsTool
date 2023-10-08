@echo off

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
