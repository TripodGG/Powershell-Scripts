# Name: Chocolatey Install
# Author: TripodGG
# Purpose: Installs Chocolatey and most common apps for Windows PCs
# License: MIT License, Copyright (c) 2025 TripodGG




# Set Execution Policy to RemoteSigned
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Scoop as admin
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"