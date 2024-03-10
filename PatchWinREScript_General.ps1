# PatchWinREScript_General.ps1
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
    [Parameter(HelpMessage="Work Directory for patch WinRE")][string]$workDir="",
    [Parameter(Mandatory=$true,HelpMessage="Path of target package")][string]$packagePath
)

# ------------------------------------
# Help functions
# ------------------------------------

# Log message
function LogMessage([string]$message)
{
    $message = "$([DateTime]::Now) - $message"
    Write-Host $message
}

function IsTPMBasedProtector
{
    $DriveLetter = $env:SystemDrive
    LogMessage("Checking BitLocker status")
    $BitLocker = Get-WmiObject -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -Filter "DriveLetter = '$DriveLetter'"
    
    if(-not $BitLocker)
    {
        LogMessage("No BitLocker object")
        return $False
    }

    $protectionEnabled = $False

    switch ($BitLocker.GetProtectionStatus().protectionStatus)
    {
        ("0") {
            LogMessage("Unprotected")
            break
        }
        ("1") {
            LogMessage("Protected")
            $protectionEnabled = $True
            break
        }
        ("2") {
            LogMessage("Unknown")
            break
        }
        default {
            LogMessage("NoReturn")
            break
        }
    }

    if (!$protectionEnabled)
    {
        LogMessage("Bitlocker isn’t enabled on the OS")
        return $False
    }

    $ProtectorIds = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID
    $return = $False

    foreach ($ProtectorID in $ProtectorIds)
    {
        $KeyProtectorType = $BitLocker.GetKeyProtectorType($ProtectorID).KeyProtectorType

        switch($KeyProtectorType)
        {
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

    if ($return)
    {
        LogMessage("Has TPM-based protector")
    }
    else
    {
        LogMessage("Doesn't have TPM-based protector")
    }

    return $return
}

function SetRegistrykeyForSuccess
{
    reg add HKLM\SOFTWARE\Microsoft\PushButtonReset /v WinREPathScriptSucceed /d 1 /f
}

function TargetfileVersionExam([string]$mountDir)
{
    # Exam target binary
    $targetBinary=$mountDir + "\Windows\System32\bootmenuux.dll"
    LogMessage("TargetFile: " + $targetBinary)
    $realNTVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($targetBinary).ProductVersion
    $versionString = "$($realNTVersion.Split('.')[0]).$($realNTVersion.Split('.')[1])"
    $fileVersion = $($realNTVersion.Split('.')[2])
    $fileRevision = $($realNTVersion.Split('.')[3])
    LogMessage("Target file version: " + $realNTVersion)

    if (!($versionString -eq "10.0"))
    {
        LogMessage("Not Windows 10 or later")
        return $False
    }

    $hasUpdated = $False

    #Windows 10, version 1507 10240.19567
    #Windows 10, version 1607 14393.5499
    #Windows 10, version 1809 17763.3646
    #Windows 10, version 2004 1904X.2247
    #Windows 11, version 21H2 22000.1215
    #Windows 11, version 22H2 22621.815

    switch ($fileVersion) {
        "10240" {
            LogMessage("Windows 10, version 1507")
            if ($fileRevision -ge 19567)
            {
                LogMessage("Windows 10, version 1507 with revision " + $fileRevision + " >= 19567, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        "14393" {
            LogMessage("Windows 10, version 1607")
            if ($fileRevision -ge 5499)
            {
                LogMessage("Windows 10, version 1607 with revision " + $fileRevision + " >= 5499, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        "17763" {
            LogMessage("Windows 10, version 1809")
            if ($fileRevision -ge 3646)
            {
                LogMessage("Windows 10, version 1809 with revision " + $fileRevision + " >= 3646, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        "19041" {
            LogMessage("Windows 10, version 2004")
            if ($fileRevision -ge 2247)
            {
                LogMessage("Windows 10, version 2004 with revision " + $fileRevision + " >= 2247, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        "22000" {
            LogMessage("Windows 11, version 21H2")
            if ($fileRevision -ge 1215)
            {
                LogMessage("Windows 11, version 21H2 with revision " + $fileRevision + " >= 1215, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        "22621" {
            LogMessage("Windows 11, version 22H2")
            if ($fileRevision -ge 815)
            {
                LogMessage("Windows 11, version 22H2 with revision " + $fileRevision + " >= 815, updates have been applied")
                $hasUpdated = $True
            }
            break
        }
        default {
            LogMessage("Warning: unsupported OS version")
        }
    }

    return $hasUpdated
