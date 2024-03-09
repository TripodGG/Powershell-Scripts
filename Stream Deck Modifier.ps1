# Name: Elgato Stream Deck Modifier
# Author: TripodGG
# Purpose: Change various settings for the Elgato Stream Deck
# License: MIT License, Copyright (c) 2024 TripodGG



# Error logging function
function Log-Error {
    param (
        [string]$errorMessage
    )

    $logFilePath = Join-Path $env:USERPROFILE "StreamDeckModError.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logEntry = "$timestamp - $errorMessage"
    Add-Content -Path $logFilePath -Value $logEntry
}

try {
	# Default install location
	$defaultInstallPath = "C:\Program Files\Elgato\StreamDeck"

	# Check if required folders exist
	$requiredFolders = @("assets", "css", "js")
	$missingFolders = $requiredFolders | Where-Object { -not (Test-Path -Path (Join-Path $defaultInstallPath $_)) }

	if ($missingFolders.Count -gt 0) {
		Write-Host "The following required folders are missing: $($missingFolders -join ', ')."
		Write-Host "To continue, please download and extract the Stream Deck SDK files manually:"
		Write-Host "1. Download Stream Deck Javascript SDK from: https://github.com/elgatosf/streamdeck-javascript-sdk"
		Write-Host "2. Extract the downloaded files to the Stream Deck directory."

		# Wait for 10 seconds
		Start-Sleep -Seconds 10

		# Launch default browser with SDK download link
		$sdkDownloadUrl = "https://github.com/elgatosf/streamdeck-javascript-sdk"
		Start-Process $sdkDownloadUrl

		# Wait for the user to complete the manual installation
		Write-Host "After installation, run the script again."
		exit
	}

	# Check if src folder and com.elgato.template.sdPlugin folder exist
	$srcFolderPath = Join-Path $defaultInstallPath "src"
	$pluginFolderPath = Join-Path $srcFolderPath "com.elgato.template.sdPlugin"

	if (-not (Test-Path -Path $pluginFolderPath)) {
		Write-Host "The 'com.elgato.template.sdPlugin' folder is missing in the 'src' folder."
		Write-Host "To continue, please download and extract the Stream Deck Javascript Template Plugin files manually:"
		Write-Host "1. Download Stream Deck Javascript Template Plugin from: https://github.com/elgatosf/streamdeck-plugin-template"
		Write-Host "2. Extract the downloaded files to the 'src' folder."

		# Wait for 10 seconds
		Start-Sleep -Seconds 10

		# Launch default browser with plugin download link
		$pluginDownloadUrl = "https://github.com/elgatosf/streamdeck-plugin-template"
		Start-Process $pluginDownloadUrl

		# Wait for the user to complete the manual installation
		Write-Host "After installation, run the script again."
		exit
	}

	# If all required folders are present, continue with the script
	Write-Host "All required folders are present. Continuing with the script..."

	# Check system for NirCmd
	$nircmdPath = $null
	
	# Define NirCmd download URL
	$nircmdDownloadUrl = "https://www.nirsoft.net/utils/nircmd.zip"

	# Search for NirCmd on the C: drive and all subfolders recursively
	$nircmdCandidates = Get-ChildItem -Path C:\ -Recurse -Filter "nircmd.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

	# Check if $nircmdCandidates array is not empty
	if ($nircmdCandidates -and $nircmdCandidates.Count -gt 0) {
		foreach ($nircmdCandidate in $nircmdCandidates) {
			Write-Host "Checking $nircmdCandidate"
			# Check if $nircmdCandidate is not null before calling Test-Path
			if ($nircmdCandidate -and (Test-Path -Path $nircmdCandidate)) {
				$nircmdPath = $nircmdCandidate
				Write-Host "NirCmd found at: $nircmdPath"
				break
			}
		}
	}

	# If NirCmd is not found on any drive, prompt the user to download
	if ($null -eq $nircmdPath) {
		Write-Host "NirCmd not found on any available drive."

		# Prompt the user to download NirCmd
		Write-Host "To continue, please download NirCmd from: $nircmdDownloadUrl"
		Write-Host "After downloading, extract the contents to your C: drive and run the script again."

		# Wait for 10 seconds
		Start-Sleep -Seconds 5
		
		# Launch default browser with plugin download link
		$nircmdDownloadUrl = "https://www.nirsoft.net/utils/nircmd.zip"
		Start-Process $nircmdDownloadUrl

		# Provide additional instructions
		Write-Host "After extracting nircmd.exe, run the script again."
		exit
	}

	# If NirCmd is found, continue with the script
	Write-Host "NirCmd found at: $nircmdPath"


    # Function to set the audio output device using NirCmd
    function Set-AudioOutputDevice($deviceName, $nircmdPath) {
        $output = & $nircmdPath setdefaultsounddevice "$deviceName"
        Write-Host $output
    }

# Get the number of connected Stream Decks
$numberOfStreamDecks = [ESD.SDK]::GetNumberOfDevices()

# Check if Stream Decks are connected
if ($numberOfStreamDecks -eq 0) {
    Write-Host "Error: No Stream Decks detected."
    exit
}

# ASCII art within the parent menu
Write-Host @"
 ______    _              _____________    
/_  __/___(_)__  ___  ___/ / ___/ ___( )___
 / / / __/ / _ \/ _ \/ _  / (_ / (_ /|/(_-<
/_/ /_/ /_/ .__/\___/\_,_/\___/\___/  /___/
         /_/                               
"@

# Parent menu to choose Stream Deck
do {
    Write-Host "Elgato Stream Deck Selector Menu"
    for ($i = 0; $i -lt $numberOfStreamDecks; $i++) {
        $streamDeckName = [ESD.SDK]::GetDeviceNameByIndex($i)
        Write-Host "$($i + 1). $streamDeckName"
    }
    Write-Host "0. Exit"

    $streamDeckChoice = Read-Host "Enter the number of the Stream Deck you want to modify (0 to exit):"

		switch ($streamDeckChoice) {
			{ $_ -ge 1 -and $_ -le $numberOfStreamDecks } {
				# Connect to the selected Stream Deck
				$streamDeck = [ESD.SDK]::OpenStreamDeckByIndex($streamDeckChoice - 1)
					
				# Show the modifier menu
					do {
						Write-Host "Elgato Stream Deck Modifier Menu"
						Write-Host "Enter the number of the modification you would like to make:"
						
						Write-Host "1. Set Brightness"
						Write-Host "2. Set Button Title"
						Write-Host "3. Set Button Image"
						Write-Host "4. Modify Text Color"
						Write-Host "5. Set Audio Output Device"
						Write-Host "6. Exit"

						$choice = Read-Host "Enter your choice (1-6):"
					
				switch ($choice) {
						1 {
							# Set brightness(range is 0 to 100)
							do {
								$brightnessValue = Read-Host "Enter brightness value (1-100):"
								$brightnessValue = [int]$brightnessValue
							} while ($brightnessValue -lt 1 -or $brightnessValue -gt 100)
							# Set brightness to the user-provided value (range is 0 to 100)
							$streamDeck.SetBrightness($brightnessValue)
						}
						2 {
							# Set the title of the first button to "New Title"
							# Prompt the user for the button number
							do {
								$buttonIndex = Read-Host "Enter the button number (from left to right, top to bottom) you want to modify:"
								$buttonIndex = [int]$buttonIndex
							} while ($buttonIndex -lt 0 -or $buttonIndex -ge $streamDeck.NumberOfKeys)
							# Prompt the user for the new title
							$newTitle = Read-Host "Enter the new title for button $($buttonIndex):"
							# Set the title of the specified button
							$streamDeck.SetTitle($buttonIndex, $newTitle)
						}
						3 {
							# Set an image to the first button (replace 'path\to\image.png' with the actual path)
							# Prompt the user for the button number
							do {
								$buttonIndex = Read-Host "Enter the button number (from left to right, top to bottom) you want to modify:"
								$buttonIndex = [int]$buttonIndex
							} while ($buttonIndex -lt 0 -or $buttonIndex -ge $streamDeck.NumberOfKeys)
							# Prompt the user for the path to the image
							$imagePath = Read-Host "Enter the path to the image for button $($buttonIndex):"
							# Set an image to the specified button
							$streamDeck.SetImage($buttonIndex, $imagePath)
						}
						4 {
							# Modify text color
							do {
								$buttonIndex = Read-Host "Enter the button number (from left to right, top to bottom) you want to modify (or 'all' for all buttons):"
								if ($buttonIndex -ne 'all') {
									$buttonIndex = [int]$buttonIndex
								}
							} while ($buttonIndex -ne 'all' -and ($buttonIndex -lt 0 -or $buttonIndex -ge $streamDeck.NumberOfKeys))
							
							$textColor = Read-Host "Enter the text color (color name or hexadecimal value, e.g., 'red' or '#FF0000' for red):"
							$textColor = $textColor -replace '^#', ''  # Remove leading '#' if present
							
							# Convert color names to hex codes
							if ($textColor -match '^[a-zA-Z]+$') {
								$colorFromName = [System.Drawing.Color]::FromName($textColor)
								$textColor = $colorFromName.Name
							}
							
							# Validate hex code
							if ($textColor -match '^[0-9A-Fa-f]{6}$') {
								$textColor = "#$textColor"
							} else {
								Write-Host "Invalid color input. Please enter a valid color name or hexadecimal value."
								continue
							}
							
							if ($buttonIndex -eq 'all') {
								# Change text color for all buttons
								for ($i = 0; $i -lt $streamDeck.NumberOfKeys; $i++) {
									$streamDeck.SetTextColor($i, $textColor)
								}
							} else {
								# Change text color for the specified button
								$streamDeck.SetTextColor($buttonIndex, $textColor)
							}
						}
						5 {
							# Set audio output device
							$audioDevices = & "$nircmdPath\nircmd.exe" showsounddevices output
							Write-Host "Available Audio Output Devices:"
							Write-Host $audioDevices
							$selectedDevice = Read-Host "Enter the name of the audio output device you want to set:"
							Set-AudioOutputDevice $selectedDevice $nircmdPath
						}
						6 {
							# Exit the script
							Write-Host "Exiting Elgato Stream Deck Modifier."
							$streamDeck.Close()
							exit
						}
						Default {
							Write-Host "Invalid choice. Please enter a number between 1 and 6."
						}
					}
				} while ($choice -ne 5)  # Repeat the modifier menu until the user chooses to exit
				
				# Close the Stream Deck connection
				$streamDeck.Close()
			}
			0 {
				# Exit the script
				Write-Host "Exiting Elgato Stream Deck Selector."
				exit
			}
			Default {
				Write-Host "Invalid choice. Please enter a number between 0 and $($numberOfStreamDecks)."
			}
		}
	} while ($true)
} catch {
    $errorMessage = "Critical error: $_"
    Log-Error $errorMessage
    Write-Host "An error occurred. Please check the error log at $($env:USERPROFILE)\StreamDeckModError.log for details."
    exit
}