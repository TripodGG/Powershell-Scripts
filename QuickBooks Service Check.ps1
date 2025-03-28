# QuickBooks Service Check
# Written by TripodGG
# Purpose: Check to see if the QuickBooks Desktop services are running and start them if they are not. This should be used as a scheduled task.
# License: MIT License, Copyright (c) 2024 TripodGG




# Ensure log directory exists
$logDirectory = "C:\Scripts"
if (!(Test-Path -Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}

# Set monthly log file path: C:\Scripts\ServiceCheckLog_YYYY-MM.txt
$logFileName = "ServiceCheckLog_{0}.txt" -f (Get-Date -Format "yyyy-MM")
$logPath = Join-Path -Path $logDirectory -ChildPath $logFileName

# Function to log messages
function Log-Message {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append
}

# Log start of script run
Log-Message "----- Running service check -----"

# Check and start QBCFMonitorService
$service1 = Get-Service -Name 'QBCFMonitorService' -ErrorAction SilentlyContinue
if ($null -ne $service1) {
    if ($service1.Status -ne 'Running') {
        Start-Service -Name 'QBCFMonitorService'
        Log-Message "Started QBCFMonitorService (was not running)."
    } else {
        Log-Message "QBCFMonitorService is already running."
    }
} else {
    Log-Message "QBCFMonitorService not found on this system."
}

# Check for QuickBooksDBxx service
$qbService = Get-Service | Where-Object { $_.Name -match '^QuickBooksDB\d{2}$' }

if ($qbService) {
    foreach ($svc in $qbService) {
        if ($svc.Status -ne 'Running') {
            Start-Service -Name $svc.Name
            Log-Message "Started $($svc.Name) (was not running)."
        } else {
            Log-Message "$($svc.Name) is already running."
        }
    }
} else {
    Log-Message "No QuickBooksDBxx service found."
}

# Log end of script run
Log-Message "----- Service check complete -----`n"
