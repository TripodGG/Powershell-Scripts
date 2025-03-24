# Name: Chocolatey Install
# Author: TripodGG
# Purpose: Installs Chocolatey and most common apps for Windows PCs
# License: MIT License, Copyright (c) 2025 TripodGG




# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Visual Studio redistributables and most common apps
choco install vcredist2008 vcredist2010 vcredist2012 vcredist2013 vcredist140 adobereader 7zip git notepadplusplus googlechrome firefox vlc javaruntime

# Clear the screen
Clear