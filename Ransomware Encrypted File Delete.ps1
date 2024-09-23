# Name: Ransomware Encrypted File Delete
# Author: TripodGG
# Purpose: Prompt for and delete all encrypted files after a ransomware attack
# License: MIT License, Copyright (c) 2024 TripodGG



# Prompt user for the ransomware file extension
$encrypted_ext = Read-Host "Enter the ransomware file extension (e.g., .trinity)"

# Prompt user for the top-level folder to scan
$folder_path = Read-Host "Enter the top-level folder path to scan for encrypted files"

# Confirm if the user wants to proceed with the deletion
$initial_confirmation = Read-Host "Are you sure you want to proceed with scanning and deleting files? (yes/y or no/n)"
if ($initial_confirmation -notmatch "^(yes|y)$") {
    Write-Host "Operation canceled. Exiting script."
    exit
}

# Final confirmation before deleting files
$log_file = [System.IO.Path]::Combine($HOME, "RansomwareDelete.log")
$final_confirmation = Read-Host "This will delete all $encrypted_ext files. Are you absolutely sure? This cannot be undone. The log file will be saved at $log_file. (yes/y or no/n)"
if ($final_confirmation -notmatch "^(yes|y)$") {
    Write-Host "Operation canceled. Exiting script."
    exit
}

# Set up log file in the user's home directory
Add-Content -Path $log_file -Value "Starting file deletion process for extension $encrypted_ext at $(Get-Date)"

# Start the scanning and deletion process
Write-Host "Scanning for files with extension $encrypted_ext in $folder_path and all subfolders..."

# Get and delete the files with the specified extension
Get-ChildItem -Path $folder_path -Recurse -Filter "*$encrypted_ext" -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Deleting: $($_.FullName)"
    # Log the deletion to the file
    Add-Content -Path $log_file -Value "Deleted file: $($_.FullName) at $(Get-Date)"
    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
}

# Final message and log entry
Write-Host "All $encrypted_ext encrypted files have been deleted. A log file has been saved to: $log_file"
Add-Content -Path $log_file -Value "Completed file deletion process at $(Get-Date)"
