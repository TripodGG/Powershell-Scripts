# Name: Clear All Browser Cache
# Author: TripodGG
# Purpose: Search for all installed web browsers and clear all cached data
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Function to check for installed browsers and clear cached data
function Clear-BrowserCaches {
    param()

    function Clear-BrowserCache($browserName, $cachePath) {
        if (Test-Path $cachePath -PathType Container) {
            Remove-Item -Path $cachePath -Force -Recurse
            Write-Host "$browserName cache cleared successfully."
        } else {
            Write-Host "$browserName not detected."
        }
    }

    # Define an array of browsers to check
    $browsers = @(
        @{Name='Google Chrome'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'; CachePath="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"},
        @{Name='Mozilla Firefox'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe'; CachePath="$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2"},
        @{Name='Microsoft Edge'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe'; CachePath="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"},
        @{Name='Opera'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\opera.exe'; CachePath="$env:APPDATA\Opera Software\Opera Stable\Cache"},
        @{Name='Opera GX'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\opera_gx.exe'; CachePath="$env:APPDATA\Opera Software\Opera GX Stable\Cache"},
        @{Name='Brave'; Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\brave.exe'; CachePath="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache"},
        @{Name='Internet Explorer'; Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE'; CachePath="$env:LOCALAPPDATA\Microsoft\Windows\INetCache"},
        @{Name='Safari'; Path='HKLM:\Software\Apple Inc.\Safari'; CachePath="$env:USERPROFILE\AppData\Local\Packages\AppleInc.Safari_*\AC\Microsoft\Crypto\RSA\S-1-5-21-*\Cache"}
    )

    foreach ($browser in $browsers) {
        Clear-BrowserCache -browserName $browser.Name -cachePath $browser.CachePath
    }

    Write-Host "All detected browsers cached data has been cleared."
}

# Clear all browser cache without user interaction
Clear-BrowserCaches
