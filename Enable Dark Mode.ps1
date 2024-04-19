# Enable Dark Mode
# Author: TripodGG
# Purpose: Enable dark mode for all Windows apps
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Notify the user
Write-Host "Enabling Dark Mode..." -ForegroundColor Yellow

# Pause for 5 seconds
Start-Sleep -Seconds 5

# Set the registry key to enable dark mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
$dir = ls "$PsScriptRoot\..\"

# Success message
Write-Host "Dark mode enabled" -ForegroundColor Green

# Pause for 5 seconds
Start-Sleep -Seconds 5

# Clear the screen and return to a PS prompt
Clear-Host
