@echo off
powershell.exe -ExecutionPolicy Bypass -Command "& {Unblock-File -Path '%~dp0PS_AdBlock*.ps1' -Confirm:$false}"
for %%f in ("%~dp0PS_AdBlock*.ps1") do powershell.exe -ExecutionPolicy Bypass -File "%%f"
pause
exit
