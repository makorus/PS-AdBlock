@echo off
REM Check if script is being executed as admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM No administrative privileges found if %ERRORLEVEL% is set
if '%ERRORLEVEL%' NEQ '0' (
echo Requesting administrative privileges...
goto GetAdminPrivileges
) else ( goto RunningAsAdmin )
:GetAdminPrivileges
REM Temporarily create VBS file to request administrative privileges (file will be deleted at the end)
echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\getadmin.vbs"
"%TEMP%\getadmin.vbs"
exit /B
:RunningAsAdmin
if exist "%TEMP%\getadmin.vbs" ( del "%TEMP%\getadmin.vbs" )
powershell.exe -ExecutionPolicy Bypass -Command "& {Unblock-File -Path '%~dp0PS_AdBlock*.ps1' -Confirm:$false}"
for %%f in ("%~dp0PS_AdBlock*.ps1") do powershell.exe -ExecutionPolicy Bypass -File "%%f"
pause
exit
