# Basic Backup Script
# Written by TripodGG
# Purpose: Basic Copy of files and folders from a source location to a separate destination
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Define source and destination paths
$sourcePath = "C:\Users\admin\Desktop"
$destinationPath = "\\w2k22\Data\Test"

# Get the current timestamp for log file naming
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFilePath = "C:\BackupLogs\BackupLog_$timestamp.txt"

# Function to log messages to both the console and the log file
function Write-Log {
    param (
        [string]$message
    )
    $message | Out-File -FilePath $logFilePath -Append
    Write-Host $message
}

# Start logging
Write-Log "Backup started at $(Get-Date)"

# Recursively get all files from the source directory
$sourceFiles = Get-ChildItem -Path $sourcePath -Recurse -File

foreach ($file in $sourceFiles) {
    # Construct the relative path from the source root
    $relativePath = $file.FullName.Substring($sourcePath.Length).TrimStart('\')

    # Construct the full path for the destination file
    $destFile = Join-Path -Path $destinationPath -ChildPath $relativePath

    # Ensure the destination directory exists
    $destDir = Split-Path -Path $destFile -Parent
    if (-Not (Test-Path -Path $destDir)) {
        New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        Write-Log "Created directory: $destDir"
    }

    # Check if the destination file exists
    if (-Not (Test-Path -Path $destFile)) {
        # If the file doesn't exist in the destination, copy it
        Copy-Item -Path $file.FullName -Destination $destFile -Force
        Write-Log "Copied new file: $($file.FullName) to $destFile"
    } else {
        # If the file exists, compare the LastWriteTime to see if it should be replaced
        $sourceFileLastWriteTime = (Get-Item $file.FullName).LastWriteTime
        $destFileLastWriteTime = (Get-Item $destFile).LastWriteTime

        if ($sourceFileLastWriteTime -gt $destFileLastWriteTime) {
            # If the source file is newer, copy it to the destination
            Copy-Item -Path $file.FullName -Destination $destFile -Force
            Write-Log "Updated file: $($file.FullName) to $destFile"
        } else {
            Write-Log "Skipped file: $($file.FullName) as it's up-to-date"
        }
    }
}

# Finish logging
Write-Log "Backup completed at $(Get-Date)"

# Clear the screen
Clear-Host