# Basic file copy script
# Author: TripodGG
# Purpose: Copy files from one location to another within PowerShell
# License: MIT License, Copyright (c) 2024 TripodGG




# Function to prompt user for directory creation
function PromptForDirectoryCreation {
    $createDestination = $null
    $attempt = 0
    while ($attempt -lt 3) {
        $createDestination = Read-Host "Destination directory does not exist. Would you like to create it? (y/n)"
        if ($createDestination -eq 'y' -or $createDestination -eq 'yes') {
            # Create the destination directory
            $null = New-Item -ItemType Directory -Path $destinationFolder
            return $true
        } elseif ($createDestination -eq 'n' -or $createDestination -eq 'no') {
            # Prompt for a different destination directory
            $destinationFolder = Read-Host "Enter the destination folder path"
            return $false
        } else {
            Write-Host "Invalid input. Please enter 'y' or 'n'."
            $attempt++
        }
    }
    Write-Host "No valid destination directory provided. Exiting script."
    exit
}

# Clear the screen
Clear-Host

# Prompt user for source folder
$sourceFolder = Read-Host "Enter the source folder path"

# Prompt user for destination folder
$destinationFolder = Read-Host "Enter the destination folder path"

# Check if the destination folder exists
while (-not (Test-Path -Path $destinationFolder -PathType Container)) {
    $created = PromptForDirectoryCreation
    if (-not $created) {
        # Prompt for a different destination folder
        $destinationFolder = Read-Host "Enter a different destination folder path"
    }
}

# Prompt user for verbosity
$verboseInput = Read-Host "Would you like to run this script verbosely? (y/n)"
$verbose = $verboseInput -eq 'y' -or $verboseInput -eq 'yes'

# Get all files in the source folder
$filesToCopy = Get-ChildItem -Path $sourceFolder

foreach ($file in $filesToCopy) {
    # Build the destination file path
    $destinationFile = Join-Path -Path $destinationFolder -ChildPath $file.Name
    
    # Check if the file already exists in the destination
    if (-not (Test-Path -Path $destinationFile)) {
        # Copy the file to the destination
        if ($verbose) {
            Copy-Item -Path $file.FullName -Destination $destinationFolder -Verbose
        } else {
            Copy-Item -Path $file.FullName -Destination $destinationFolder
        }
    }
}


# Clear the screen and return to a PS prompt
Clear-Host
