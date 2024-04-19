# Remove Provisioned Apps
# Author: TripodGG
# Purpose: Remove unwanted Apps that come with Windows within a GUI
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Inform the user of the status
Write-Host "Removing all Windows Provisioned apps..."
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."

# Remove unwanted Apps
Get-AppxProvisionedPackage -online | Out-GridView -PassThru | Remove-AppxProvisionedPackage -online

# Success Message
Write-Host "Windows Provisioned apps have been successfully removed."

# Prompt the user to reboot
$choice = Read-Host "Do you want to reboot? (Y/N)"
	if ($choice -eq "Y" -or $choice -eq "Yes") {
		Restart-Computer -Force
	} elseif ($choice -eq "N" -or $choice -eq "No") {
		Write-Host "Exiting script. Reboot your PC at your earliest convenience to finalize the removal."
	} else {
		Write-Host "Invalid choice. Exiting script."
	}

# Clear the screen and return to a PS prompt
Clear-Host