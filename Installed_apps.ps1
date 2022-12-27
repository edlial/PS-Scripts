$latest_version = "2.05"
$penta_path = "C:\Program Files\5Q"
$info_json = (Get-Content "$penta_path\Installed_apps_info.json" -Raw) | ConvertFrom-Json
$local_version = $info_json.psobject.Properties.Where({ $_.Name -eq "script_version" }).Value

if ($local_version -eq $latest_version) {
    Write-Host "[ $(hostname) ] Script is already up to date !"
}
else {
    Write-Host "Applying Updates !"
    #update json file locally
    $jsonVar = @"
{
    "script_name": "Installed_apps",
    "script_version": "$latest_version",
    "computer_name": "$(hostname)"
}
"@
    
    If (!(test-path -PathType container $penta_path)) {
        New-Item -ItemType Directory -Path $penta_path
    }

    $jsonVar | Out-File "$penta_path\Installed_apps_info.json"

    Start-Transcript -OutputDirectory "$penta_path"

    Write-Host "======================================="
    Write-Host "---       Start Managing Apps       ---"
    Write-Host "           $(hostname)                 "
    Write-Host "======================================="

    #check if chocolatey is installed
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is installed !"
    }
    else {
        Write-Host "Chocolatey is not installed !"
        Write-Host "Installing Chocolatey !"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    #get installed applications
    $installedApps = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, UninstallString | Where-Object { $_.DisplayName -ne $null }
    #get installed 64 bit applications
    $installedApps64 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, UninstallString | Where-Object { $_.DisplayName -ne $null }
    #combine the two
    $installedApps = $installedApps + $installedApps64
    $choco_installed_apps = $(choco list --local-only)


    #create array of applications to install using choco names
    $apps_to_install = @('adobereader','7zip','GoogleChrome','microsoft-edge','vlc')

    #create array of applications to uninstall
    #using Win32 names
    $appsToUninstall = @("winrar","Adobe Acrobat","7-Zip","Google Chrome","Microsoft Edge","VLC")
    #using choco names
    $choco_apps_to_uninstall = @("winrar","adobereader","7zip","GoogleChrome","microsoft-edge","vlc")

    

    #loop through appsToUninstall and uninstall the applications
    foreach ($app in $appsToUninstall) {
        $installedApps | Where-Object { $_.DisplayName -like "*$app*" } | ForEach-Object {        
            if ($_.UninstallString -like "*MsiExec.exe*") {
                Write-Host "Uninstalling $($_.DisplayName)."
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($_.PSChildName) /qn" -Wait 
            }
            else {
                Write-Host "Uninstalling $($_.DisplayName)."
                Start-Process -FilePath $_.UninstallString -ArgumentList "/S" -Wait 
            }
        }
    }

    #loop through choco_apps_to_uninstall and uninstall the applications
    foreach ($app in $choco_apps_to_uninstall) {
        write-host "Uninstalling $app."
        choco uninstall -x -y --force $app
    }

    #loop through applications to install
    foreach ($app in $apps_to_install) {
        choco install -y -x --force $app
        # #check if application is installed
        # if (($installedApps | Where-Object { $_.DisplayName -like $app }) -or ($choco_installed_apps | Select-String $app)) {
        #     Write-Host "$app is already installed."
        # }
        # else {
        #     Write-Host "Installing $app."
        #     choco install -y -x --force $app
        # }
    }

    choco upgrade all -y

    Write-Host "======================================="
    Write-Host "---     Finished Managing Apps      ---"
    Write-Host "           $(hostname)                 "
    Write-Host "======================================="
}