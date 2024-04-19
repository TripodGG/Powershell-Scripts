# Reinstall Built-In Apps
# Author: TripodGG
# Purpose: Reinstall all built-in modern apps in a single step
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host

# Inform the user of the status
Write-Host "Reinstalling all Windows Built-In apps..."
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."
Start-Sleep -Seconds 1
Write-Host "..."

# Reinstall all built-in apps
Get-AppxPackage -allusers | foreach {Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode -ErrorAction SilentlyContinue}

# Success Message
Write-Host "Windows Built-In apps have been successfully reinstalled."

# Prompt the user to reboot
$choice = Read-Host "Do you want to reboot? (Y/N)"
	if ($choice -eq "Y" -or $choice -eq "Yes") {
		Restart-Computer -Force
	} elseif ($choice -eq "N" -or $choice -eq "No") {
		Write-Host "Exiting script. Reboot your PC at your earliest convenience to finalize the installation."
	} else {
		Write-Host "Invalid choice. Exiting script."
	}

# Clear the screen and return to a PS prompt
Clear-Host