# Remove 3rd Party Telemetry
# Author: TripodGG
# Purpose: Block and disable telemetry features of 3rd party apps
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Block Google Chrome Software Reporter Tool
Write-Host "Disabling Google Chrome Telemetry..." -ForegroundColor Yellow
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name ChromeCleanupEnabled -Type String -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name ChromeCleanupReportingEnabled -Type String -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name MetricsReportingEnabled -Type String -Value 0 -Force
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe")) {
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe" -Force | Out-Null
Write-Host "Google Chrome Software Reporter Tool has been successfully blocked." -ForegroundColor Green
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe" -Name "Debugger" -Type String -Value %windir%\System32\taskkill.exe -Force 
Write-Host "Google Chrome telemetry successfully disabled." -ForegroundColor Green

###- Disable Google Update service
Write-Host "Disabling Google Chrome auto-update..." -ForegroundColor Cyan
Get-ScheduledTask -TaskName "GoogleUpdateTaskMachineCore" | Disable-ScheduledTask
Get-ScheduledTask -TaskName "GoogleUpdateTaskMachineUA" | Disable-ScheduledTask
Write-Host "Google Chrome auto-update successfully disabled." -ForegroundColor Green

###- Disable Mozilla Firefox telemetry
Write-Host "Disabling Mozilla Firefox Telemetry..." -ForegroundColor Yellow
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Mozilla\Firefox" -Name DisableTelemetry -Type DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Mozilla\Firefox" -Name DisableDefaultBrowserAgent -Type DWord -Value 1 -Force
Write-Host "Mozilla Firefox telemetry successfully disabled." -ForegroundColor Green

###- Disable Media Player telemetry
Write-Host "Disabling Windows Media Player Telemetry..." -ForegroundColor Cyan
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\MediaPlayer\Preferences" -Name UsageTracking -Type DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name PreventCDDVDMetadataRetrieval -Type DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name PreventMusicFileMetadataRetrieval -Type DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name PreventRadioPresetsRetrieval -Type DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM" -Name DisableOnline -Type DWord -Value 1 -Force
Set-Service WMPNetworkSvc -StartupType Disabled
Write-Host "Windows Media Player telemetry successfully disabled." -ForegroundColor Green

###- Disable Microsoft Office telemetry
Write-Host "Disabling Microsoft Office Telemetry..." -ForegroundColor Yellow
Get-ScheduledTask -TaskName "OfficeTelemetryAgentFallBack2016" | Disable-ScheduledTask
Get-ScheduledTask -TaskName "OfficeTelemetryAgentLogOn2016" | Disable-ScheduledTask
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Office\15.0\osm" -Name Enablelogging -Type DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Office\15.0\osm" -Name EnableUpload -Type DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" -Name Enablelogging -Type DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" -Name EnableUpload -Type DWord -Value 0 -Force
Write-Host "Microsoft Office telemetry successfully disabled." -ForegroundColor Green

###- Disable CCleaner Monitoring
Write-Host "Disabling CCleaner Telemetry..." -ForegroundColor Cyan
Stop-Process -name CCleaner*
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name Monitoring -Type String -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name HelpImproveCCleaner -Type String -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name SystemMonitoring -Type String -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name UpdateAuto -Type String -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name UpdateCheck -Type String -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Piriform\CCleaner" -Name CheckTrialOffer -Type String -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Piriform\CCleaner" -Name (Cfg)GetIpmForTrial -Type String -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Piriform\CCleaner" -Name (Cfg)SoftwareUpdater -Type String -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Piriform\CCleaner" -Name (Cfg)SoftwareUpdaterIpm -Type String -Value 0 -Force
Get-ScheduledTask -TaskName "CCleaner Update" | Disable-ScheduledTask
Write-Host "CCleaner telemetry successfully disabled." -ForegroundColor Green

###- Disable Dropbox Update service
Write-Host "Disabling Dropbox auto-update..." -ForegroundColor Yellow
Get-ScheduledTask -TaskName "DropboxUpdateTaskMachineCore" | Disable-ScheduledTask
Get-ScheduledTask -TaskName "DropboxUpdateTaskMachineUA" | Disable-ScheduledTask
Write-Host "Dropbox auto-update telemetry successfully disabled..." -ForegroundColor Green

# Clear the screen and return to a PS prompt
Start-Sleep 5
Clear-Host
