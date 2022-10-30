$latest_version = "1.0"
$info_json = (Get-Content "C:\Temp\5Q\info.json" -Raw) | ConvertFrom-Json
$local_version = $info_json.psobject.Properties.Where({ $_.Name -eq "script_version" }).Value

if ($local_version -eq $latest_version) {
    Write-Host "Script is already up to date !"
}
else {
    Write-Host "Applying Updates !"
#update json file locally
$MyJsonVar = @"
{
    "script_name": "Control_installed_apps",
    "script_version": "$latest_version"
}
"@
    $MyJsonVar | Out-File "C:\Temp\5Q\info.json"
} 




# #Install choco if it's not installed
# Get-PackageProvider -Name "Chocolatey" -ForceBootstrap

# $LogFolder = "C:\Temp\5Q"
# If (Test-Path $LogFolder) {
#     Write-Output "$LogFolder exists. Skipping."
# }
# Else {
#     Write-Output "The folder '$LogFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
#     Start-Sleep 1
#     New-Item -Path "$LogFolder" -ItemType Directory
#     Write-Output "The folder $LogFolder was successfully created."
# }

# Start-Transcript -OutputDirectory "$LogFolder"

# $to_install = @('7zip','notepadplusplus','git')
# $to_remove_choco = @('puppet-agent','googlechrome')
# $to_remove_winget = @('Puppet.puppet-agent','Google.Chrome')

# foreach ($package in $to_install) {
#     Write-Host "Installing $package."
#     choco install -y $package
# }

# foreach ($package in $to_remove_winget) {
#     Write-Host "Winget is trying to remove $package."
#     winget uninstall -h $package
# }

# foreach ($package in $to_remove_choco) {
#     Write-Host "Choco is trying to remove $package."
#     choco uninstall -y $package
# }

# choco upgrade all
# winget upgrade --all -h