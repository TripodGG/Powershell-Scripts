# Name: QuickBooks H202 Error fix
# Author: TripodGG
# Purpose: A confirmed working fix for the H202 error that a user will receive when in a networked QuickBooks environment
# License: MIT License, Copyright (c) 2024 TripodGG




# Clear the screen
Clear-Host

# Function to find and stop QuickBooksDB services
function Stop-QuickBooksDBServices {
    $quickBooksDBServices = Get-Service | Where-Object { $_.Name -match '^QuickBooksDB\d{2}$' }
    foreach ($service in $quickBooksDBServices) {
        Stop-Service -Name $service.Name -Force
        Write-Output "Service $($service.Name) has been stopped."
    }
    return $quickBooksDBServices
}

# Function to restart QuickBooksDB services
function Start-QuickBooksDBServices {
    param (
        [Parameter(Mandatory=$true)]
        [array]$services
    )
    foreach ($service in $services) {
        Start-Service -Name $service.Name
        Write-Output "Service $($service.Name) has been restarted."
    }
}

# Stop the DNS service
Stop-Service -Name "DNS" -Force
Write-Output "DNS service has been stopped."

# Stop QuickBooksDB services
$quickBooksDBServices = Stop-QuickBooksDBServices

# Prompt the user for a port number
$portNumber = Read-Host -Prompt 'Open QuickBooks Database Server Manager and navigate to the "Port Monitor" tab. Enter the port number listed for your version of QuickBooks'

# Validate the port number
if ($portNumber -match '^\d+$' -and [int]$portNumber -ge 1 -and [int]$portNumber -le 65535) {
    # Execute the netsh command with the provided port number
    $command = "netsh int ipv4 add excludedportrange protocol=udp startport=$portNumber numberofports=1"
    try {
        Invoke-Expression $command
        Write-Output "UDP Port $portNumber has been excluded from Dynamic Port Allocation."

        # Start the DNS service
        Start-Service -Name "DNS"
        Write-Output "DNS service has been restarted."

        # Restart QuickBooksDB services
        Start-QuickBooksDBServices -services $quickBooksDBServices
    } catch {
        Write-Error "Failed to exclude UDP Port $portNumber. Please ensure you have administrative privileges and try again."

        # Start the DNS service in case of error
        Start-Service -Name "DNS"
        Write-Output "DNS service has been restarted."

        # Restart QuickBooksDB services in case of error
        Start-QuickBooksDBServices -services $quickBooksDBServices
    }
} else {
    Write-Error "Invalid port number. Please enter a number between 1 and 65535."

    # Start the DNS service in case of invalid input
    Start-Service -Name "DNS"
    Write-Output "DNS service has been restarted."

    # Restart QuickBooksDB services in case of invalid input
    Start-QuickBooksDBServices -services $quickBooksDBServices
}
