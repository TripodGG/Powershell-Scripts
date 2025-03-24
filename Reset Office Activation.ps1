# Set the save path
$savepath = "$env:systemdrive\%temp%"
If (!(Test-Path $savepath)) {
    New-Item -ItemType Directory -Force -Path $savepath | Out-Null
}
# Define the download URL and construct paths
$downloadUrl = 'https://aka.ms/SaRA_EnterpriseVersionFiles'
$urlParts = $downloadUrl.Split('/')
$installername = $urlParts[-1]
$installerpath = "$savepath\$installername.zip"
# Download the SaRA files
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerpath
# Create a subdirectory for extraction
$extractionSubdir = Join-Path -Path $savepath -ChildPath ($installername -replace '\.zip$', '')
New-Item -ItemType Directory -Force -Path $extractionSubdir | Out-Null
# Unzip the downloaded file to the subdirectory
Expand-Archive -Path $installerpath -DestinationPath $extractionSubdir -Force
# Define the executable path
$executablePath = Join-Path -Path $extractionSubdir -ChildPath 'SaRAcmd.exe'
# Define splatting for Start-Process
$startProcessParams = @{
    FilePath     = $executablePath
    ArgumentList = @(
        "-S", "ResetOfficeActivation",
        "-AcceptEula",
        "-CloseOffice"
    )
    NoNewWindow  = $true
    Wait         = $true
}
# Start the process
Start-Process @startProcessParams