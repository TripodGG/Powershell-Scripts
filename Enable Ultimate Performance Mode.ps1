# Enable Ultimate Performance Power Plan
# Author: TripodGG
# Purpose: Enable Ultimate Performance power plan
# License: MIT License, Copyright (c) 2024 TripodGG




# Clear the screen
Clear-Host

# Prompt the status
Write-Host "Enabling Ultimate Perfomance mode..."

# Pause for 5 seconds
Start-Sleep -Seconds 5

# Enable Ultimate Performance power plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 

# Success Message
Write-Host "Ultimate Performance power plan has been successfully enabled. Now open Settings and navigate to System > Power & sleep > Additional Power Settings and set the Ultimate Performance power plan."

# Pause for 5 seconds
Start-Sleep -Seconds 5

# Clear the screen and return to a PS prompt
Clear-Host
