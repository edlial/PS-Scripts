$latest_version = "2.0"
$penta_path = "C:\Program Files\5Q"
$info_json = (Get-Content "$penta_path\Installed_apps_info.json" -Raw) | ConvertFrom-Json
$local_version = $info_json.psobject.Properties.Where({ $_.Name -eq "script_version" }).Value

if ($local_version -eq $latest_version) {
    Write-Host "Script is already up to date !"
}
else {
    Write-Host "Applying Updates !"
    #update json file locally
    $jsonVar = @"
{
    "script_name": "Installed_apps",
    "script_version": "$latest_version"
}
"@
    
    If (!(test-path -PathType container $penta_path)) {
        New-Item -ItemType Directory -Path $penta_path
    }

    $jsonVar | Out-File "$penta_path\Installed_apps_info.json"

    Start-Transcript -OutputDirectory "$penta_path"

    Write-Host "======================================="
    Write-Host "---       Start Managing Apps       ---"
    Write-Host "======================================="

    #Install choco if it's not installed
    Get-PackageProvider -Name "Chocolatey" -ForceBootstrap
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    $to_install = @('7zip', 'adobereader')
    $to_remove = @('puppet-agent') 

    foreach ($package in $to_install) {
        Write-Host "Installing $package."
        choco install -y $package
    }

    foreach ($package in $to_remove) {
        Write-Host "Choco is trying to remove $package."
        choco uninstall -yx $package
    }

    choco upgrade all
}