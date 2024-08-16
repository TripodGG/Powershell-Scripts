# Update Windows Store Apps
# Author: TripodGG
# Purpose: Update Windows Store Apps
# License: MIT License, Copyright (c) 2024 TripodGG



param (
    [switch]$RunSilent
)

# Function to write output only if -RunSilent is not specified
function Write-OutputIfNotSilent {
    param (
        [string]$message
    )
    if (-not $RunSilent) {
        Write-Output $message
    }
}

# This script will run an update check for Microsoft Store apps.
Write-OutputIfNotSilent "Starting update check for Microsoft Store apps..."

$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$result = $wmiObj.UpdateScanMethod()

Write-OutputIfNotSilent "Update check completed."

# Optionally, display the result if not silent
if (-not $RunSilent) {
    Write-Output "Result: $result"
}
