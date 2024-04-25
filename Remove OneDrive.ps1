# Remove OneDrive integration
# Author: TripodGG
# Purpose: Remove OneDrive integration
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Set the execution policy
Set-ExecutionPolicy -RemoteSigned

# Inform the user about possible error messages
Write-Host "Should any error messages pop up during the removal of OneDrive, do not worry. You can ignore them. The script is checking for files after they've been removed. This is expected behavior." -ForegroundColor Blue

# Import modules
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

# Stop the OneDrive process
Write-Host "Stopping OneDrive processes..." -ForegroundColor Yellow
taskkill.exe /F /IM "OneDrive.exe"

# Stop explorer.exe to prevent OneDrive from restarting while being uninstalled
taskkill.exe /F /IM "explorer.exe"

# Wait for explorer.exe to fully stop
Start-Sleep 10

# Uninstall OneDrive
Write-Host "Uninstalling OneDrive..." -ForegroundColor Cyan
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

Write-Host "Removing residual OneDrive files..." -ForegroundColor Yellow
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
# check if directory is empty before removing:
If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
}

# Disable OneDrive GPO
Write-Host "Disabling OneDrive policies via Group Policy" -ForegroundColor Cyan
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

# Remove OneDrive from file explorer
Write-Host "Removing OneDrive from file explorer sidebar..." -ForegroundColor Yellow
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
Set-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
Set-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
Remove-PSDrive "HKCR"

# Prevent OneDrive from running under any new users
Write-Host "Removing run hook for new users..." -ForegroundColor Cyan
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

# Remove OneDrive from the start menu
Write-Host "Removing OneDrive's Start menu entry..." -ForegroundColor Yellow
Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

# Remove OneDrive's scheduled task
Write-Host "Removing OneDrive scheduled task..." -ForegroundColor Cyan
Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

# Restart explorer.exe
Write-Host "Restarting explorer..." -ForegroundColor Yellow
Start-Process "explorer.exe"

# Wait for explorer to load
Start-Sleep 10

# Remove any additional residual files
Write-Host "Removing any additional residual OneDrive files..." -ForegroundColor Cyan
foreach ($item in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    Takeown-Folder $item.FullName
    Remove-Item -Recurse -Force $item.FullName
}

# Success message
Write-Host "OneDrive has been successfully removed from Windows." -ForegroundColor Green

# Clear the screen and return to a PS prompt
Start-Sleep 5
Clear-Host
