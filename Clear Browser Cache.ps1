# Name: Clear All Browser Cache
# Author: TripodGG
# Purpose: Search for all installed web browsers and clear all cached data
# License: MIT License, Copyright (c) 2024 TripodGG


#Function to clear browser cache
function Clear-BrowserCaches {
    param()

    function Clear-BrowserCache($browserName, $cachePath) {
        if (Test-Path $cachePath -PathType Container) {
            $clearCache = Read-Host -Prompt "Do you want to clear the cache for $browserName? (Y/N)"
            if ($clearCache -eq 'Y' -or $clearCache -eq 'y') {
                Remove-Item -Path $cachePath -Force -Recurse
                Write-Host "$browserName cache cleared successfully."
            } else {
                Write-Host "Skipping $browserName cache."
            }
        } else {
            Write-Host "$browserName not detected."
        }
    }

    Clear-BrowserCache -browserName 'Google Chrome' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'Google\Chrome\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'Mozilla Firefox' -cachePath ([System.IO.Path]::Combine($env:APPDATA, 'Mozilla\Firefox\Profiles', '*\cache2'))
    Clear-BrowserCache -browserName 'Microsoft Edge' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Edge\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'Opera' -cachePath ([System.IO.Path]::Combine($env:APPDATA, 'Opera Software\Opera Stable\Cache'))
    Clear-BrowserCache -browserName 'Opera GX' -cachePath ([System.IO.Path]::Combine($env:APPDATA, 'Opera Software\Opera GX Stable\Cache'))
    Clear-BrowserCache -browserName 'Brave' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'BraveSoftware\Brave-Browser\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'Safari' -cachePath ([System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Local\Packages\AppleInc.Safari_*\AC\Microsoft\Crypto\RSA\S-1-5-21-*\'))
    Clear-BrowserCache -browserName 'Chromium' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'Chromium\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'Internet Explorer' -cachePath "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    Clear-BrowserCache -browserName 'Vivaldi' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'Vivaldi\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'Gnome Web' -cachePath ([System.IO.Path]::Combine($env:HOME, '.cache\epiphany\cache'))
    Clear-BrowserCache -browserName 'Maxthon' -cachePath ([System.IO.Path]::Combine($env:APPDATA, 'Maxthon3\UserData\Users\Guest\Cache'))
    Clear-BrowserCache -browserName 'SlimBrowser' -cachePath ([System.IO.Path]::Combine($env:APPDATA, 'SlimBrowser\User Data\Default\Cache'))
    Clear-BrowserCache -browserName 'UC Browser' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'UCBrowser\Cache'))
    Clear-BrowserCache -browserName 'Konqueror' -cachePath ([System.IO.Path]::Combine($env:HOME, '.cache\kde\*'))
    Clear-BrowserCache -browserName 'Slimjet Browser' -cachePath ([System.IO.Path]::Combine($env:LOCALAPPDATA, 'Slimjet\User Data\Default\Cache'))

    Write-Host "All detected browser caches checked."
}

# Call the function
Clear-BrowserCaches
