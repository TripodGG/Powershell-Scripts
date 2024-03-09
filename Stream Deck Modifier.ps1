# Name: Elgato Stream Deck Modifier
# Author: TripodGG
# Purpose: Change various settings for the Elgato Stream Deck
# License: MIT License, Copyright (c) 2024 TripodGG



# Check if Stream Deck SDK is installed
$registryPath = "HKLM:\SOFTWARE\Elgato\StreamDeck"
$installPath = Get-ItemPropertyValue -Path $registryPath -Name "InstallPath"

if (-not $installPath) {
    Write-Host "The Stream Deck SDK is a required component but could not be found. Would you like to download it now? (Y/N)"
    $userResponse = Read-Host

    if ($userResponse -eq 'Y' -or $userResponse -eq 'y') {
        $sdkDownloadUrl = "https://developer.elgato.com/documentation/stream-deck/sdk/download/windows/"
        Start-Process $sdkDownloadUrl

        # Wait for the user to install the SDK and then exit
        Write-Host "Please install the Stream Deck SDK and run the script again."
        exit
    } else {
        Write-Host "Stream Deck SDK not found. Please make sure it is installed."
        exit
    }
}

# Check if Chocolatey is installed
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
if (-not $chocoInstalled) {
    Write-Host "Chocolatey not found. Installing Chocolatey Package Manager..."

    # Download and install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Check if installation was successful
    $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

    if (-not $chocoInstalled) {
        Write-Host "Error: Chocolatey installation failed. Please install Chocolatey manually from https://chocolatey.org/install and run the script again."
        exit
    }
}

# Check the registry for NirCmd installation path
$nircmdInstallPath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NirCmd' -Name 'InstallLocation'

if (-not $nircmdInstallPath) {
    Write-Host "NirCmd not found. Installing NirCmd via Chocolatey..."
    choco install nircmd -y

    # Check if installation was successful
    $nircmdInstallPath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NirCmd' -Name 'InstallLocation'

    if (-not $nircmdInstallPath) {
        Write-Host "Error: NirCmd installation failed. Please install NirCmd manually from https://www.nirsoft.net/utils/nircmd.html and run the script again."
        exit
    }
}

# Set the path to the installed NirCmd
$nircmdPath = $nircmdInstallPath

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
                        # Set brightness (range is 0 to 100)
                        do {
                            $brightnessValue = Read-Host "Enter brightness value (1-100):"
                            $brightnessValue = [int]$brightnessValue
                        } while ($brightnessValue -lt 1 -or $brightnessValue -gt 100)
                        $streamDeck.SetBrightness($brightnessValue)
                    }
                    2 {
                        # Set button title
                        do {
                            $buttonIndex = Read-Host "Enter the button number (from left to right, top to bottom) you want to modify:"
                            $buttonIndex = [int]$buttonIndex
                        } while ($buttonIndex -lt 0 -or $buttonIndex -ge $streamDeck.NumberOfKeys)
                        $newTitle = Read-Host "Enter the new title for button $buttonIndex:"
                        $streamDeck.SetTitle($buttonIndex, $newTitle)
                    }
                    3 {
                        # Set button image
                        do {
                            $buttonIndex = Read-Host "Enter the button number (from left to right, top to bottom) you want to modify:"
                            $buttonIndex = [int]$buttonIndex
                        } while ($buttonIndex -lt 0 -or $buttonIndex -ge $streamDeck.NumberOfKeys)
                        $imagePath = Read-Host "Enter the path to the image for button $buttonIndex:"
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
