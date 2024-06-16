# Name: Azure AD and Exchange Online tasks
# Author: TripodGG
# Purpose: Written to perform common tasks within Azure AD (Encarta) and Exchange Online
# License: MIT License, Copyright (c) 2024 TripodGG



# Clear the screen
Clear-Host


###########################
# Functions & definitions #
###########################

function Log-Error {
    param (
        [string]$errorMessage
    )

    $errorLogPath = Join-Path $env:USERPROFILE 'Documents\AADScriptError.log'
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $errorMessage"
    $logEntry | Out-File -Append -FilePath $errorLogPath
}

# Function to test administrative privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}



##########################
# Installing modules and #
# Connecting to services #
##########################

# Inform the user about the authentication process
Clear-Host
    Write-Host @"
	
** ATTENTION **

You will be asked to authenticate four times - for Azure AD, AIP, Exchange Online, and the MSOnline services. This is to ensure you are properly connected to all services, confirming all available functions within this script will work as intended.

If you are missing any of the required modules, they will be automoatically installed on to your computer.

                    
"@
$confirmation = Read-Host "Do you understand the above statements and wish to proceed? (y/n)"

if ($confirmation -ne 'y' -and $confirmation -ne 'yes') {
    Write-Host "Operation cancelled."
    exit
}

# Check if AzureAD module is installed, if not, install it
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Write-Output "Checking administrative privileges..."
    if (Test-Administrator) {
        Write-Output "Installing Azure AD module..."
        try {
            Install-Module -Name AzureAD -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Warning "Automatic installation of AzureAD module failed. Please install it manually."
            Write-Warning "To install manually, open PowerShell as an administrator and run: Install-Module -Name AzureAD -Force -AllowClobber"
        }
    } else {
        Write-Warning "Administrative privileges required to install the AzureAD module."
        Write-Warning "Please run this script as an administrator or install the module manually."
    }
}

# Check if AIPService module is installed, if not, install it
if (-not (Get-Module -Name AIPService -ListAvailable)) {
    Write-Output "Checking administrative privileges..."
    if (Test-Administrator) {
        Write-Output "Installing AIP Service module..."
        try {
            Install-Module -Name AIPService -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Warning "Automatic installation of AIPService module failed. Please install it manually."
            Write-Warning "To install manually, open PowerShell as an administrator and run: Install-Module -Name AIPService -Force -AllowClobber"
        }
    } else {
        Write-Warning "Administrative privileges required to install the AIPService module."
        Write-Warning "Please run this script as an administrator or install the module manually."
    }
}

# Check if ExchangeOnlineManagement module is installed, if not, install it
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Write-Output "Checking administrative privileges..."
    if (Test-Administrator) {
        Write-Output "Installing Exchange Online Management module..."
        try {
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Warning "Automatic installation of ExchangeOnlineManagement module failed. Please install it manually."
            Write-Warning "To install manually, open PowerShell as an administrator and run: Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber"
        }
    } else {
        Write-Warning "Administrative privileges required to install the ExchangeOnlineManagement module."
        Write-Warning "Please run this script as an administrator or install the module manually."
    }
}

# Check if MSOnline module is installed, if not, install it
if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Write-Output "Checking administrative privileges..."
    if (Test-Administrator) {
        Write-Output "Installing MSOnline module..."
        try {
            Install-Module -Name MSOnline -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Warning "Automatic installation of MSOnline module failed. Please install it manually."
            Write-Warning "To install manually, open PowerShell as an administrator and run: Install-Module -Name MSOnline -Force -AllowClobber"
        }
    } else {
        Write-Warning "Administrative privileges required to install the MSOnline module."
        Write-Warning "Please run this script as an administrator or install the module manually."
    }
}

# Import required modules
Import-Module AzureAD
Import-Module ExchangeOnlineManagement
Import-Module AIPService
Import-Module MSOnline

# Authenticate to Azure AD, AIPService, Exchange Online, and MSOnline using modern authentication
try {
    Connect-AzureAD
} catch {
    Log-Error "Failed to connect to Azure AD. Error: $_"
    Write-Host "Failed to connect to Azure AD. See error log for details."
    exit
}
try {
    Connect-MsolService
} catch {
    Log-Error "Failed to connect to MSolService. Error: $_"
    Write-Host "Failed to connect to MsolService. See error log for details."
    exit
}
try {
    Connect-AIPService
} catch {
    Log-Error "Failed to connect to AIPService. Error: $_"
    Write-Host "Failed to connect to AIPService. See error log for details."
    exit
}
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



####################
# User interations #
####################

# Display menu to the user with the welcome message
$choice = 0
while ($choice -ne 13) {
    Clear-Host
    # Display ASCII art at the top of the menu
    Write-Host @"
    _                      _   ___      __  ___        _                        ___       _ _          
   /_\   ____  _ _ _ ___  /_\ |   \    / / | __|_ ____| |_  __ _ _ _  __ _ ___ / _ \ _ _ | (_)_ _  ___ 
  / _ \ |_ / || | '_/ -_)/ _ \| |) |  / /  | _|\ \ / _| ' \/ _` | ' \/ _` / -_) (_) | ' \| | | ' \/ -_)
 /_/ \_\/__|\_,_|_| \___/_/ \_\___/  /_/   |___/_\_\__|_||_\__,_|_||_\__, \___|\___/|_||_|_|_|_||_\___|
                                                                     |___/                             
"@
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
    Write-Host "11. Check if Microsoft Message Encryption is enabled"
	Write-Host "12. Test Microsoft Message Encryption"
    Write-Host "13. Exit"

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
					Clear-Host
						# Display ASCII art at the top of the menu
Write-Host @"

   __  ___        ___ ___                                
  /  |/  /__  ___/ (_) _/_ __    ___ _    __ _____ ___ ____
 / /|_/ / _ \/ _  / / _/ // /   / _ ` /   / // (_-</ -_) __/
/_/  /_/\___/\_,_/_/_/ \_, /    \_,_/    \_,_/___/\__/_/   
                      /___/                              
                           
"@
                    Write-Host "Choose an option to modify the user $($userToModify):"
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
                # Check if Microsoft Message Encryption is enabled
                $mmeEnabled = Get-IRMConfiguration | Select-Object -ExpandProperty AzureRMSLicensingEnabled
                Write-Host "Microsoft Message Encryption (MME) status: $mmeEnabled"
                break
            }
			12 {
				# Test Microsoft Message Encryption
				$senderAddress = Read-Host "Enter the email address you would like to test"
				$recipientAddress = Read-Host "Enter an email address to test to (this will *NOT* send an email)"

				$testResult = Test-IRMConfiguration -Sender $senderAddress -Recipient $recipientAddress
				Write-host "Test Result:"
				Write-Host $testResult

				if ($testResult.Result -eq "Failed to acquire RMS templates") {
					Write-Host "Test failed with the error message: $($testResult.Error)"
					Write-Host "Attempting to fix the issue..."
					
					$RMSConfig = Get-AipServiceConfiguration
					$LicenseUri = $RMSConfig.LicensingIntranetDistributionPointUrl
					Set-IRMConfiguration -LicensingLocation $LicenseUri
					Set-IRMConfiguration -InternalLicensingEnabled $true
					
					Write-Host "Configuration updated. Retesting..."
					Test-IRMConfiguration -Sender $senderAddress -Recipient $recipientAddress
				} else {
					Write-Host "Test successful!"
				}
				break
			}
            13 {
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

# Disconnect from all services
Disconnect-AzureAD -Confirm:$false
Disconnect-AIPService
Disconnect-ExchangeOnline -Confirm:$false

# Clear the screen before Exiting
Clear-Host
