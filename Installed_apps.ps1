$latest_version = "1.0"
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

    # Write-Host "======================================="
    # Write-Host "---       Start Managing Apps       ---"
    # Write-Host "======================================="

    Start-Transcript -OutputDirectory "$penta_path"

    #Install choco if it's not installed
    Get-PackageProvider -Name "Chocolatey" -ForceBootstrap

    $to_install = @('7zip', 'adobereader')
    $to_remove_choco = @('puppet-agent') 
    $to_remove_winget = @('Puppet.puppet-agent')

    foreach ($package in $to_install) {
        Write-Host "Installing $package."
        choco install -y $package
    }

    foreach ($package in $to_remove_winget) {
        Write-Host "Winget is trying to remove $package."
        winget uninstall -h $package
    }

    foreach ($package in $to_remove_choco) {
        Write-Host "Choco is trying to remove $package."
        choco uninstall -y $package
    }

    choco upgrade all
    winget upgrade --all -h
}