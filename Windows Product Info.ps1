# Name: Windows Product Information Lookup
# Author: TripodGG
# Purpose: Retrieve Windows product information from registry
# License: MIT License, Copyright (c) 2024 TripodGG



# Function to retrieve registry value
function Get-RegistryValue {
    param (
        [string]$keyPath,
        [string]$valueName
    )

    try {
        $value = (Get-ItemProperty -Path $keyPath -Name $valueName).$valueName
        return $value
    } catch {
        Write-Host ("Error retrieving {0}: {1}" -f $valueName, $_.Exception.Message)
        return $null
    }
}

# Function to convert DigitalProductId to product key
function ConvertToKey($digitalProductId) {
    $keyOffset = 52
    $chars = "BCDFGHJKMPQRTVWXY2346789"
    $keyOutput = ""

    $cur = 0
    $i = 28
    $x = 14

    do {
        $cur = $cur * 256
        $cur = $digitalProductId[$x + $keyOffset] + $cur
        $digitalProductId[$x + $keyOffset] = [math]::floor($cur / 24) -band 255
        $cur = $cur % 24
        $x--
        
        $i--

        $keyOutput = $chars[$cur] + $keyOutput

        if (((29 - $i) % 6) -eq 0 -and $i -ne -1) {
            $i--
            $keyOutput = "-" + $keyOutput
        }
    } while ($i -ge 0)

    return $keyOutput
}

# Main execution
$digitalProductId = Get-RegistryValue -keyPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -valueName 'DigitalProductId'
$digitalProductId4 = Get-RegistryValue -keyPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -valueName 'DigitalProductId4'
$productName = Get-RegistryValue -keyPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -valueName 'ProductName'
$buildLab = Get-RegistryValue -keyPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -valueName 'BuildLab'
$displayVersion = Get-RegistryValue -keyPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -valueName 'DisplayVersion'

$output = @()

if ($digitalProductId -ne $null) {
    $productKey = ConvertToKey $digitalProductId
    $output += "Windows Product Information:",
               "  Digital Product ID: $productKey"
} else {
    $output += "Unable to retrieve Digital Product ID."
}

if ($digitalProductId4 -ne $null) {
    $productKey4 = ConvertToKey $digitalProductId4
    $output += "  Digital Product ID4 Key: $productKey4"
} else {
    $output += "Unable to retrieve DigitalProductId4."
}

if ($productName -ne $null) {
    $output += "  Product Name: $productName"
}

if ($buildLab -ne $null) {
    $output += "  Build: $buildLab"
}

if ($displayVersion -ne $null) {
    $output += "  Display Version: $displayVersion"
}

# Display output
$output | ForEach-Object { Write-Host $_ }

# Prompt user for clipboard copy
$copyToClipboard = Read-Host "Do you want to copy the output to the clipboard? (Yes/No)"

if ($copyToClipboard -eq 'Y' -or $copyToClipboard -eq 'Yes' -or $copyToClipboard -eq 'y' -or $copyToClipboard -eq 'yes') {
    $output | Set-Clipboard
    Write-Host "Output copied to clipboard."
} else {
    Write-Host "Output not copied to clipboard."
}
