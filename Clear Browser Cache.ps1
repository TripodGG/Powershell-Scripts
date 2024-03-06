# Name: Clear All Browser Cache
# Author: TripodGG
# Purpose: Search for all installed web browsers and clear all cached data
# License: MIT License, Copyright (c) 2024 TripodGG


#Function to clear browser cache
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

    function Confirm-ClearAllCaches {
        $clearAllCaches = Read-Host -Prompt "Do you want to clear cache for all installed browsers? (Y/N)"
        if ($clearAllCaches -eq 'Y' -or $clearAllCaches -eq 'yes') {
            foreach ($browser in $browsers) {
                Clear-BrowserCache -browserName $browser.Name -cachePath $browser.CachePath
            }
            Write-Host "All installed browsers cache has been cleared."
        } elseif ($clearAllCaches -eq 'N' -or $clearAllCaches -eq 'no') {
            $confirmSkip = Read-Host -Prompt "Are you sure you don't want to clear any browser cache? (Y/N)"
            if ($confirmSkip -eq 'Y' -or $confirmSkip -eq 'yes') {
                $confirmReallySkip = Read-Host -Prompt "Are you REALLY sure you don't want to clear any browser cache? (Y/N)"
                if ($confirmReallySkip -eq 'Y' -or $confirmReallySkip -eq 'yes') {
                    $confirmReallyReallySkip = Read-Host -Prompt "Are you *REALLY* REALLY sure you don't want to clear any browser cache? (Y/N)"
                    if ($confirmReallyReallySkip -eq 'Y' -or $confirmReallyReallySkip -eq 'yes') {
                        Write-Host "Really?! Why did you run this script?"
                        exit
                    } elseif ($confirmReallyReallySkip -eq 'N' -or $confirmReallyReallySkip -eq 'no') {
                        # Return to the original prompt
                        Confirm-ClearAllCaches
                    }
                } elseif ($confirmReallySkip -eq 'N' -or $confirmReallySkip -eq 'no') {
                    # Return to the original prompt
                    Confirm-ClearAllCaches
                }
            } elseif ($confirmSkip -eq 'Y' -or $confirmSkip -eq 'yes') {
                Write-Host "Why did you run this script?"
                exit
            }
        } else {
            # Return to the original prompt
            Confirm-ClearAllCaches
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
        # Add more browsers as needed
    )

    Confirm-ClearAllCaches
}

# Clear all browser cache
Clear-BrowserCaches
