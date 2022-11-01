$latest_version = "1.6"
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

    Function Install-WinGet {
        #Install the latest package from GitHub
        [cmdletbinding(SupportsShouldProcess)]
        [alias("iwg")]
        [OutputType("None")]
        [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
        Param(
            [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
            [switch]$Passthru
        )
    
        Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"
    
        if ($PSVersionTable.PSVersion.Major -eq 7) {
            Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
            return
        }
    
        #test for requirement
        $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
        if (-Not $requirement) {
            Write-Verbose "Installing Desktop App Installer requirement"
            Try {
                Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
            }
            Catch {
                Throw $_
            }
        }
    
        $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"
    
        Try {
            Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
            $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
    
            Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
            #$data = $get | Select-Object -first 1
            $data = $get[1].assets | Where-Object name -Match 'msixbundle'
    
            $appx = $data.browser_download_url

            #$data.assets[0].browser_download_url
            Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
            If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
                $file = Join-Path -path $env:temp -ChildPath $data.name
    
                Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
                Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file
    
                Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
                Add-AppxPackage -Path $file -ErrorAction Stop
    
                if ($passthru) {
                    Get-AppxPackage microsoft.desktopAppInstaller
                }
            }
        } #Try
        Catch {
            Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
            Throw $_
        }
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
    }
    
    Install-WinGet

    #Install choco if it's not installed
    Get-PackageProvider -Name "Chocolatey" -ForceBootstrap
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    #Install winget by calling the function
    

    $to_install = @('7zip', 'adobereader')
    $to_remove_choco = @('puppet-agent') 
    $to_remove_winget = @('Puppet.puppet-agent')

    foreach ($package in $to_install) {
        Write-Host "Installing $package."
        choco install -y $package
    }

    foreach ($package in $to_remove_choco) {
        Write-Host "Choco is trying to remove $package."
        choco uninstall -yx $package
    }

    foreach ($package in $to_remove_winget) {
        Write-Host "Winget is trying to remove $package."
        winget uninstall -h $package
    }

    choco upgrade all
    winget upgrade --all -h --accept-source-agreements --accept-package-agreements
}