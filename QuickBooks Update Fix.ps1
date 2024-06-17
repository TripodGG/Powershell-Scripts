# QuickBooks update fix
# Author: TripodGG
# Purpose: Fix Error 15xxx when trying to update QuickBooks
# License: MIT License, Copyright (c) 2024 TripodGG

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
    Write-Host "This script requires administrative privileges. Please rerun this script as administrator." -ForegroundColor Red
    Log-Error -ErrorMessage "This script requires administrative privileges. Please rerun this script as administrator."
    Break
    exit
}

# Function to close QuickBooks
function Close-QuickBooks {
    param (
        [string]$ProcessName
    )

    try {
        $runningProcesses = Get-Process -Name $ProcessName -ErrorAction Stop
        $runningProcesses | ForEach-Object {
            $_.Kill()
            Write-Host "$ProcessName closed." -ForegroundColor Green
        }
    } catch {
        Log-Error -ErrorMessage "Failed to close $ProcessName $_"
    }
}

$programs = @("QBW32.exe", "QBW.exe", "QBCFMonitorService.exe", "qbupdate.exe", "QBDBMgr.exe", "QBDBMgrN.exe", "QBMapi32.exe")

foreach ($program in $programs) {
    # Check if program is running
    $process = Get-Process -Name $program -ErrorAction SilentlyContinue

    if ($process) {
        # Program is running, forcefully close it
        Close-QuickBooks -ProcessName $program
    } else {
        Write-Host "$program is not running." -ForegroundColor Yellow
    }
}

# Run system file checker to fix any errors
sfc /scannow

# Run dism to clean the image and restore health
dism /online /cleanup-image /restorehealth

# Function to launch the reboot batch file
function Launch-RebootBatch {
    try {
        $qbPath = "C:\Program Files\Intuit\QuickBooks*"
        $qbDirs = Get-ChildItem -Path $qbPath -Directory

        if ($qbDirs.Count -eq 0) {
            throw "No QuickBooks installation directory found."
        }

        $qbDir = $qbDirs | Select-Object -First 1
        $batchFilePath = Join-Path -Path $qbDir.FullName -ChildPath "reboot.bat"

        if (-Not (Test-Path -Path $batchFilePath)) {
            throw "Batch file not found: $batchFilePath"
        }

        Start-Process -FilePath $batchFilePath -Wait
    } catch {
        Write-Host "Failed to launch reboot batch file: $_" -ForegroundColor Red
        Log-Error -ErrorMessage "Failed to launch reboot batch file: $_"
    }
}

# Reboot the computer with warning prompt
Write-Host "You must reboot your computer to finish the repair. Once the computer has finished rebooting, run QuickBooks as administrator and rerun the update process. Please save your work now, then press enter to reboot your computer..."
[void][System.Console]::ReadKey($true)

# Launch the reboot batch file
Launch-RebootBatch

Write-Host "Rebooting your computer..."
shutdown -r -f -t 005
