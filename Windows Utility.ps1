# Name: Ultimate Windows Utility
# Author: TripodGG & Chris Titus (Chris Titus Tech)
# Purpose: Check and install all required package managers, then launch CTT Windows Utility
# License: MIT License, Copyright (c) 2024 TripodGG & MIT License, Copyright (c) 2022 Chris Titus



# Clear the screen
Clear-Host

# Function for error logging
function Log-Error {
    param (
        [string]$ErrorMessage
    )

    $ErrorLogPath = "$env:LOCALAPPDATA\Temp\WinUtilError.log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Construct the error message with timestamp
    $ErrorEntry = "$Timestamp - $ErrorMessage"

    # Append the error message to the error log file
    Add-Content -Path $ErrorLogPath -Value $ErrorEntry
}

# Function to check for admin privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (Test-Administrator) {
    # Perform actions requiring administrative privileges here
    Write-Host "Running with administrative privileges." -ForegroundColor Cyan
} else {
    # Log an error if administrative privileges are not available
    Log-Error -ErrorMessage "This script requires administrative privileges."
	exit
}

# Function to check for Choco and install it if necessary
function Install-Chocolatey {
    # Check if Chocolatey is installed
    if (-not (Test-Path "$env:ProgramData\chocolatey\choco.exe")) {
        # Chocolatey is not installed, so install it
        try {
            # Download and install Chocolatey
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

            # Check if Chocolatey installation was successful
            if (-not (Test-Path "$env:ProgramData\chocolatey\choco.exe")) {
                # Chocolatey installation failed, log an error
                Log-Error -ErrorMessage "Chocolatey installation failed."
            } else {
                Write-Host "Chocolatey installed successfully." -ForegroundColor Green
            }
        } catch {
            # Error occurred during Chocolatey installation, log an error
            Log-Error -ErrorMessage "An error occurred during Chocolatey installation: $_"
        }
    } else {
        Write-Host "Chocolatey install detected.  Continuing..." -ForegroundColor Yellow
    }
}

# Function to check for Winget and install it if necessary
function Install-Winget {
    # Check if Winget is installed
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Winget is not installed, so install it
        try {
            # Download and install the Windows Package Manager (Winget)
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle'))

            # Check if Winget installation was successful
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                # Winget installation failed, log an error
                Log-Error -ErrorMessage "Winget installation failed."
            } else {
                Write-Host "Winget installed successfully." -ForegroundColor Green
            }
        } catch {
            # Error occurred during Winget installation, log an error
            Log-Error -ErrorMessage "An error occurred during Winget installation: $_"
        }
    } else {
        Write-Host "Winget install detected.  Continuing..." -ForegroundColor Yellow
    }
}

# Display ASCII art at the top
Write-Host @"
 ______    _              ____________    
/_  __/___(_)__  ___  ___/ / ___/ ___/
 / / / __/ / _ \/ _ \/ _  / (_ / (_ /
/_/ /_/ /_/ .__/\___/\_,_/\___/\___/
         /_/                               

"@

# Run required install checks
Write-Host "Checking if Chocolatey is installed..."
Install-Chocolatey

Write-Host "Checking if Winget is installed..."
Install-Winget

# Launch Chris Titus Tech Windows Utility
Write-Host "Launching ChrisTitusTech Windows Utility..." -ForegroundColor Blue
Start-Sleep -Seconds 5
irm https://christitus.com/win | iex
break
