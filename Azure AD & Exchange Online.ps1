# Name: Azure AD and Exchange Online tasks
# Author: TripodGG
# Purpose: Written to perform common tasks within Azure AD (Encarta) and Exchange Online
# License: MIT License, Copyright (c) 2024 TripodGG

function Log-Error {
    param (
        [string]$errorMessage
    )

    $errorLogPath = Join-Path $env:USERPROFILE 'Documents\AADScriptError.log'
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $errorMessage"
    $logEntry | Out-File -Append -FilePath $errorLogPath
}

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
try {
    Connect-AzureAD
} catch {
    Log-Error "Failed to connect to Azure AD. Error: $_"
    Write-Host "Failed to connect to Azure AD. See error log for details."
    exit
}

# Connect to Exchange Online using modern authentication
try {
    Connect-ExchangeOnline
} catch {
    Log-Error "Failed to connect to Exchange Online. Error: $_"
    Write-Host "Failed to connect to Exchange Online. See error log for details."
    exit
}

# Retrieve organization information from Azure
$organizationInfo = Get-AzureADTenantDetail | Select-Object -ExpandProperty DisplayName
$defaultDomain = Get-AcceptedDomain | Where-Object { $_.Default -eq 'True' }

# Display menu to the user with the welcome message
$choice = 0
while ($choice -ne 11) {
    Clear-Host
    Write-Host "Welcome to $($organizationInfo)'s Azure AD and Exchange Online Server."
    Write-Host "Please choose an option below:"

    Write-Host "1. Display organization's current settings"
    Write-Host "2. List all accounts in Exchange Online"
    Write-Host "3. Get information about a user mailbox"
    Write-Host "4. Modify a user"
    Write-Host "5. Set 'Send from Alias' option on or off"
    Write-Host "6. Set 'Focused Inbox' option on or off"
    Write-Host "7. Set a mailbox to a specific type"
    Write-Host "8. Grant a user access to a shared mailbox"
    Write-Host "9. Remove a user access to a shared mailbox"
    Write-Host "10. Set a user's password to never expire"
    Write-Host "11. Exit"

    $choice = Read-Host "Enter the number of your choice"

    try {
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
                # Modify a user
                $userToModify = Read-Host "Enter the user to modify (display name or email address)"

                # Add quotes around the display name to avoid errors
                if ($userToModify -notmatch '"') {
                    $userToModify = '"' + $userToModify + '"'
                }

                $userModificationChoice = 0
                while ($userModificationChoice -ne 8) {
                    Write-Host "Choose an option to modify the user $userToModify:"
                    Write-Host "1. Change user's display name"
                    Write-Host "2. Change user's title"
                    Write-Host "3. Change user's department"
                    Write-Host "4. Add an alias"
                    Write-Host "5. Remove an alias"
                    Write-Host "6. Block Sign-in"
                    Write-Host "7. Unblock Sign-in"
                    Write-Host "8. Back to main menu"

                    $userModificationChoice = Read-Host "Enter the number of your choice"

                    switch ($userModificationChoice) {
                        1 {
                            # Change user's display name
                            $newDisplayName = Read-Host "Enter the new display name"
                            Set-AzureADUser -ObjectId $userToModify -DisplayName $newDisplayName
                            Write-Host "User's display name has been updated to $newDisplayName."
                            break
                        }
                        2 {
                            # Change user's title
                            $newTitle = Read-Host "Enter the new title"
                            Set-AzureADUser -ObjectId $userToModify -Title $newTitle
                            Write-Host "User's title has been updated to $newTitle."
                            break
                        }
                        3 {
                            # Change user's department
                            $newDepartment = Read-Host "Enter the new department"
                            Set-AzureADUser -ObjectId $userToModify -Department $newDepartment
                            Write-Host "User's department has been updated to $newDepartment."
                            break
                        }
                        4 {
                            # Add an alias
                            $newAlias = Read-Host "Enter the new alias"
                            Set-AzureADUser -ObjectId $userToModify -UserPrincipalName "$newAlias@$defaultDomain"
                            Write-Host "Alias $newAlias@$defaultDomain has been added to $userToModify."
                            break
                        }
                        5 {
                            # Remove an alias
                            $existingAliases = Get-AzureADUser -ObjectId $userToModify | Select-Object -ExpandProperty OtherMails
                            if ($existingAliases.Count -gt 0) {
                                Write-Host "Existing aliases: $($existingAliases -join ', ')"
                                $aliasToRemove = Read-Host "Enter the alias to remove"

                                if ($existingAliases -contains $aliasToRemove) {
                                    Set-AzureADUser -ObjectId $userToModify -OtherMails ($existingAliases | Where-Object {$_ -ne $aliasToRemove})
                                    Write-Host "Alias $aliasToRemove has been removed from $userToModify."
                                } else {
                                    Write-Host "Alias $aliasToRemove not found for $userToModify."
                                }
                            } else {
                                Write-Host "No aliases found for $userToModify."
                            }
                            break
                        }
                        6 {
                            # Block Sign-in
                            Set-AzureADUser -ObjectId $userToModify -UserState 'Blocked'
                            Write-Host "$userToModify has been blocked from sign-in."
                            break
                        }

                        7 {
                            # Unblock Sign-in
                            Set-AzureADUser -ObjectId $userToModify -UserState 'Active'
                            Write-Host "$userToModify has been unblocked and is now active for sign-in."
                            break
                        }
                        8 {
                            Write-Host "Returning to the main menu..."
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
                break
            }
            5 {
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
            6 {
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
            7 {
                # Set a mailbox to a specific type
                $targetMailbox = Read-Host "Enter the email address of the mailbox to be converted"
                $mailboxType = Read-Host "Enter the type of mailbox (regular, room, equipment, or shared)"
                Set-Mailbox -Identity $targetMailbox -Type $mailboxType
                Write-Host "Mailbox type has been updated."
                break
            }
            8 {
                # Grant a user access to a shared mailbox
                $userToAdd = Read-Host "Enter the user to grant access"
                $sharedMailbox = Read-Host "Enter the shared mailbox"
                Add-MailboxPermission -Identity $sharedMailbox -User $userToAdd -AccessRights FullAccess -InheritanceType All
                Write-Host "User $userToAdd has been granted access to $sharedMailbox."
                break
            }
            9 {
                # Remove a user access to a shared mailbox
                $userToRemove = Read-Host "Enter the user to remove access"
                $sharedMailboxToRemove = Read-Host "Enter the shared mailbox"
                Remove-MailboxPermission -Identity $sharedMailboxToRemove -User $userToRemove -AccessRights FullAccess -Confirm:$false
                Write-Host "User $userToRemove has been removed from access to $sharedMailboxToRemove."
                break
            }
            10 {
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
            11 {
                Write-Output "Exiting..."
                break
            }
            default {
                Write-Output "Invalid choice. Please enter a valid option."
                break
            }
        }
    } catch {
        Log-Error "Option $choice failed. Error: $_"
        Write-Host "Option $choice failed. See error log for details."
    }

    # Pause to allow the user to read the output
    Read-Host "Press Enter to continue..."
}

# Disconnect from Azure AD
    Disconnect-AzureAD -Confirm:$false

# Disconnect from Exchange Online
    Disconnect-ExchangeOnline -Confirm:$false