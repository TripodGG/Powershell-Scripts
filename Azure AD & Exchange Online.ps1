# Name: Azure AD and Exchange Online tasks
# Author: TripodGG
# Purpose: Written to perform common tasks within Azure AD (Encarta) and Exchange Online
# License: MIT License, Copyright (c) 2024 TripodGG


# Check if AzureAD module is installed, if not, install it
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Write-Output "Installing Azure AD module..."
    Install-Module -Name AzureAD -Force -AllowClobber
}

# Import required modules
Import-Module AzureAD
Import-Module ExchangeOnlineManagement

# Authenticate to Azure AD using modern authentication
Connect-AzureAD -UseDeviceAuthentication

# Get the Azure AD token
$azureAdToken = $null
try {
    $azureAdToken = (Get-AzureADAccessToken -ResourceUrl "https://graph.microsoft.com").Token
} catch {
    Write-Error "Failed to get Azure AD token. Make sure you are authenticated to Azure AD."
    Disconnect-AzureAD -Confirm:$false
    Exit
}

# Connect to Exchange Online using the Azure AD token
Connect-ExchangeOnline -AccessToken $azureAdToken

# Now you are connected to both Azure AD and Exchange Online using the same authentication

# Display menu to the user
$choice = 0
while ($choice -ne 10) {
    Clear-Host
    Write-Host "Choose an option:"
    Write-Host "1. Display organization's current settings"
    Write-Host "2. Get information about a user in Azure AD"
    Write-Host "3. Get information about a user mailbox"
    Write-Host "4. Set 'Send from Alias' option on or off"
    Write-Host "5. Turn off 'Focused Inbox'"
    Write-Host "6. Set a mailbox to a specific type"
    Write-Host "7. Grant a user access to a shared mailbox"
    Write-Host "8. Remove a user access to a shared mailbox"
    Write-Host "9. Set a user's password to never expire"
    Write-Host "10. Exit"
    
    $choice = Read-Host "Enter the number of your choice"
    
    switch ($choice) {
        1 {
            # Display organization's current settings
            Get-OrganizationConfig | Format-List
            break
        }
        2 {
            # Get information about a user in Azure AD
            $username = Read-Host "Enter the username to check"
            Get-AzureADUser -UserPrincipalName $username | Format-List
            break
        }
        3 {
            # Get information about a user mailbox
            $emailAddress = Read-Host "Enter the email address to check"
            Get-Mailbox -Identity $emailAddress | Format-List
            break
        }
        4 {
            # Set 'Send from Alias' option on or off
            $sendFromAliasEnabled = Get-OrganizationConfig | Select-Object -ExpandProperty SendFromAliasEnabled
            Write-Host "Current 'Send from Alias' status: $sendFromAliasEnabled"
            $choice = Read-Host "Do you want to change it? (y/n)"
            if ($choice -eq 'y' -or $choice -eq 'yes') {
                Set-OrganizationConfig -SendFromAliasEnabled (-not $sendFromAliasEnabled)
                Write-Host "Send from Alias option has been updated."
            }
            break
        }
        5 {
            # Turn off 'Focused Inbox'
            $focusedInboxOn = Get-Mailbox -Identity $env:USERNAME | Select-Object -ExpandProperty FocusedInboxOn
            if ($focusedInboxOn) {
                Set-Mailbox -Identity $env:USERNAME -FocusedInboxOn $false
                Write-Host "Focused Inbox has been turned off."
            } else {
                Write-Host "Focused Inbox is already disabled."
            }
            break
        }
        6 {
            # Set a mailbox to a specific type
            $targetMailbox = Read-Host "Enter the email address of the mailbox to be converted"
            $mailboxType = Read-Host "Enter the type of mailbox (regular, room, equipment, or shared)"
            Set-Mailbox -Identity $targetMailbox -Type $mailboxType
            Write-Host "Mailbox type has been updated."
            break
        }
        7 {
            # Grant a user access to a shared mailbox
            $userToAdd = Read-Host "Enter the user to grant access"
            $sharedMailbox = Read-Host "Enter the shared mailbox"
            Add-MailboxPermission -Identity $sharedMailbox -User $userToAdd -AccessRights FullAccess -InheritanceType All
            Write-Host "User $userToAdd has been granted access to $sharedMailbox."
            break
        }
        8 {
            # Remove a user access to a shared mailbox
            $userToRemove = Read-Host "Enter the user to remove access"
            $sharedMailboxToRemove = Read-Host "Enter the shared mailbox"
            Remove-MailboxPermission -Identity $sharedMailboxToRemove -User $userToRemove -AccessRights FullAccess -Confirm:$false
            Write-Host "User $userToRemove has been removed from access to $sharedMailboxToRemove."
            break
        }
        9 {
            # Set a user's password to never expire
            $userEmail = Read-Host "Enter the user's email address"
            $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userEmail'"
            if ($user) {
                $mfaStatus = $user | Select-Object -ExpandProperty StrongAuthenticationRequirements
                if ($mfaStatus -eq $null) {
                    Set-AzureADUser -ObjectId $user.ObjectId -PasswordNeverExpires $true
                    Write-Host "Password for $userEmail has been set to never expire."
                } else {
                    Write-Host "Cannot set the password to never expire until Multi-Factor Authentication is enabled."
                }
            } else {
                Write-Host "User not found."
            }
            break
        }
        10 {
            Write-Output "Exiting..."
            break
        }
        default {
            Write-Output "Invalid choice. Please enter a valid option."
            break
        }
    }
    
    # Pause to allow the user to read the output
    Read-Host "Press Enter to continue..."
}

# Disconnect from Azure AD
Disconnect-AzureAD -Confirm:$false

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
