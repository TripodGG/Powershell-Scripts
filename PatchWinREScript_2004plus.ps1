# PatchWinREScript_2004plus.ps1
################################################################################################
#
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
################################################################################################

Param (
    [Parameter(HelpMessage="Work Directory for patch WinRE")]
    [string]$workDir="",

    [Parameter(Mandatory=$true, HelpMessage="Path of target package")]
    [string]$packagePath
)

# ------------------------------------
# Help functions
# ------------------------------------

# Log message
function LogMessage([string]$message) {
    $message = "$([DateTime]::Now) - $message"
    Write-Host $message
}

function IsTPMBasedProtector {
    $DriveLetter = $env:SystemDrive
    LogMessage("Checking BitLocker status")
    $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -Filter "DriveLetter = '$DriveLetter'"
    
    if(-not $BitLocker) {
        LogMessage("No BitLocker object")
        return $False
    }

    $protectionEnabled = $False

    switch ($BitLocker.GetProtectionStatus().protectionStatus){
        "0" {
            LogMessage("Unprotected")
            break
        }
        "1" {
            LogMessage("Protected")
            $protectionEnabled = $True
            break
        }
        "2" {
            LogMessage("Uknown")
            break
        }
        default {
            LogMessage("NoReturn")
            break
        }
    }

    if (!$protectionEnabled) {
        LogMessage("Bitlocker isn’t enabled on the OS")
        return $False
    }

    $ProtectorIds = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID
    $return = $False

    foreach ($ProtectorID in $ProtectorIds){
        $KeyProtectorType = $BitLocker.GetKeyProtectorType($ProtectorID).KeyProtectorType

        switch($KeyProtectorType){
            "1" {
                LogMessage("Trusted Platform Module (TPM)")
                $return = $True
                break
            }
            "4" {
                LogMessage("TPM And PIN")
                $return = $True
                break
            }
            "5" {
                LogMessage("TPM And Startup Key")
                $return = $True
                break
            }
            "6" {
                LogMessage("TPM And PIN And Startup Key")
                $return = $True
                break
            }
            default {
                break
            }
        }#endSwitch
    }#EndForeach

    if ($return) {
        LogMessage("Has TPM-based protector")
    } else {
        LogMessage("Doesn't have TPM-based protector")
    }

    return $return
}

function SetRegistrykeyForSuccess {
    reg add HKLM\SOFTWARE\Microsoft\PushButtonReset /v WinREPathScriptSucceed /d 1 /f
}

function TargetfileVersionExam([string]$mountDir) {
    # ... (unchanged)
}

function PatchPackage([string]$mountDir, [string]$packagePath) {
    # ... (unchanged)
}

# ------------------------------------
# Execution starts
# ------------------------------------

# Check breadcrumb
if (Test-Path HKLM:\Software\Microsoft\PushButtonReset) {
    $values = Get-ItemProperty -Path HKLM:\Software\Microsoft\PushButtonReset

    if (!(-not $values)) {
        if (Get-Member -InputObject $values -Name WinREPathScriptSucceed) {
            $value = Get-ItemProperty -Path HKLM:\Software\Microsoft\PushButtonReset -Name WinREPathScriptSucceed

            if ($value.WinREPathScriptSucceed -eq 1) {
                LogMessage("This script was previously run successfully")
                exit 1
            }
        }
    }
}

if ([string]::IsNullorEmpty($workDir)) {
    LogMessage("No input for mount directory")
    LogMessage("Use default path from temporary directory")
    $workDir = [System.IO.Path]::GetTempPath()
}

LogMessage("Working Dir: " + $workDir)
$name = "CA551926-299B-27A55276EC22_Mount"
$mountDir = Join-Path $workDir $name
LogMessage("MountDir: " + $mountdir)

# Delete existing mount directory
if (Test-Path $mountDir) {
    LogMessage("Mount directory: " + $mountDir + " already exists")
    LogMessage("Try to unmount it")
    Dism /unmount-image /mountDir:$mountDir /discard

    if (!($LASTEXITCODE -eq 0)) {
        LogMessage("Warning: unmount failed: " + $LASTEXITCODE)
    }

    LogMessage("Delete existing mount direcotry " + $mountDir)
    Remove-Item $mountDir -Recurse
}

# Create mount directory
LogMessage("Create mount directory " + $mountDir)
New-Item -Path $mountDir -ItemType Directory

# Set ACL for mount directory
LogMessage("Set ACL for mount directory")
icacls $mountDir /inheritance:r
icacls $mountDir /grant:r SYSTEM:"(OI)(CI)(F)"
icacls $mountDir /grant:r *S-1-5-32-544:"(OI)(CI)(F)"

# Mount WinRE
LogMessage("Mount WinRE:")
reagentc /mountre /path $mountdir

if ($LASTEXITCODE -eq 0) {
    # ... (unchanged)
} else {
    LogMessage("Mount failed: " + $LASTEXITCODE)
}

# Cleanup Mount directory in the end
LogMessage("Delete mount direcotry")
Remove-Item $mountDir -Recurse
