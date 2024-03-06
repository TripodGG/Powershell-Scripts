# Name: Azure AD and Exchange Online tasks
# Author: TripodGG
# Purpose: Written to perform common tasks within Azure AD (Encarta) and Exchange Online
# License: MIT License, Copyright (c) 2024 TripodGG


# Inform the user about the authentication process
Write-Host "You will be asked to authenticate twice - once for Azure AD and once for Exchange Online."
$confirmation = Read-Host "Do you understand and want to proceed? (y/n)"

if ($confirmation -ne 'y' -and $confirmation -ne 'yes') {
    Write-Host "Operation canceled."
    exit
}

# Check if AzureAD module is installed, if not, install it
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Write-Output "Installing Azure AD module..."
    Install-Module -Name AzureAD -Force -AllowClobber
}

# Import required modules
Import-Module AzureAD
Import-Module ExchangeOnlineManagement

# Authenticate to Azure AD using modern authentication
Connect-AzureAD 

# Connect to Exchange Online using modern authentication
Connect-ExchangeOnline

# Retrieve organization information from Azure
$organizationInfo = Get-AzureADTenantDetail | Select-Object -ExpandProperty DisplayName

# Display menu to the user with the welcome message
$choice = 0
while ($choice -ne 10) {
    Clear-Host
    Write-Host "Welcome to $($organizationInfo)'s Azure AD and Exchange Online Server."
    Write-Host "Please choose an option below:"
    
    Write-Host "1. Display organization's current settings"
    Write-Host "2. List all accounts in Exchange Online"
    Write-Host "3. Get information about a user mailbox"
    Write-Host "4. Set 'Send from Alias' option on or off"
    Write-Host "5. Set 'Focused Inbox' option on or off"
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
            # List all accounts in Exchange Online
            Get-Mailbox | Select-Object DisplayName, UserPrincipalName
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
            # Set 'Focused Inbox' option on or off
            $focusedInboxOn = Get-Mailbox -Identity $env:USERNAME | Select-Object -ExpandProperty FocusedInboxOn
            Write-Host "Current 'Focused Inbox' status: $focusedInboxOn"
            $choice = Read-Host "Do you want to change it? (y/n)"
            if ($choice -eq 'y' -or $choice -eq 'yes') {
                Set-Mailbox -Identity $env:USERNAME -FocusedInboxOn (-not $focusedInboxOn)
                Write-Host "Focused Inbox option has been updated."
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