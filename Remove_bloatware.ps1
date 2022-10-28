$Bloatware = @(
    #Unnecessary Windows 10 AppX Apps

    "3DBuilder"
    "Microsoft3DViewer"
    "AppConnector"
    "BingFinance"
    "BingNews"
    "BingSports"
    "BingTranslator"
    "BingWeather"
    "BingFoodAndDrink"
    "BingHealthAndFitness"
    "BingTravel"
    "MinecraftUWP"
    "GamingServices"
    # "WindowsReadingList"
    "GetHelp"
    "Getstarted"
    "Messaging"
    "Microsoft3DViewer"
    "MicrosoftSolitaireCollection"
    "NetworkSpeedTest"
    "News"
    "Lens"
    "Sway"
    "OneNote"
    "OneConnect"
    "People"
    "Print3D"
    "SkypeApp"
    "Todos"
    "Wallet"
    "Whiteboard"
    "WindowsAlarms"
    "windowscommunicationsapps"
    "WindowsFeedbackHub"
    "WindowsMaps"
    "WindowsPhone"
    "WindowsSoundRecorder"
    "XboxApp"
    "ConnectivityStore"
    "CommsPhone"
    "ScreenSketch"
    "TCUI"
    "XboxGameOverlay"
    "XboxGamingOverlay"
    "XboxGameCallableUI"
    "XboxIdentityProvider"
    "XboxSpeechToTextOverlay"
    "MixedReality.Portal"
    "ZuneMusic"
    "ZuneVideo"
    "YourPhone"
    "Getstarted"
    "MicrosoftOfficeHub"

    #Sponsored Windows 10 AppX Apps
    #Add sponsored/featured apps to remove in the "*AppName*" format
    "EclipseManager"
    "ActiproSoftwareLLC"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Duolingo-LearnLanguagesforFree"
    "PandoraMediaInc"
    "CandyCrush"
    "BubbleWitch3Saga"
    "Wunderlist"
    "Flipboard"
    "Twitter"
    "Facebook"
    "Royal Revolt"
    "Sway"
    "Speed Test"
    "Dolby"
    "Viber"
    "ACGMediaPlayer"
    "Netflix"
    "OneCalendar"
    "LinkedInforWindows"
    "HiddenCityMysteryofShadows"
    "Hulu"
    "HiddenCity"
    "AdobePhotoshopExpress"
    "HotspotShieldFreeVPN"

    #Optional: Typically not removed but you can if you need to
    "Advertising"
    "MSPaint"
    "MicrosoftStickyNotes"
    "Windows.Photos"
    #"WindowsCalculator"
    #"WindowsStore"

    # HPBloatware Packages
    "HPJumpStarts"
    "HPPCHardwareDiagnosticsWindows"
    "HPPowerManager"
    "HPPrivacySettings"
    "HPSupportAssistant"
    "HPSureShieldAI"
    "HPSystemInformation"
    "HPQuickDrop"
    "HPWorkWell"
    "myHP"
    "HPDesktopSupportUtilities"
    "HPQuickTouch"
    "HPEasyClean"
    "HPSystemInformation"
)

## Teams Removal - Source: https://github.com/asheroto/UninstallTeams
function getUninstallString($match) {
    return (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -like "*$match*" }).UninstallString
}
            
$TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')
            
Write-Output "Stopping Teams process..."
Stop-Process -Name "*teams*" -Force -ErrorAction SilentlyContinue
        
Write-Output "Uninstalling Teams from AppData\Microsoft\Teams"
if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
    # Uninstall app
    $proc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru
    $proc.WaitForExit()
}
        
Write-Output "Removing Teams AppxPackage..."
Get-AppxPackage "*Teams*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage "*Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        
Write-Output "Deleting Teams directory"
if ([System.IO.Directory]::Exists($TeamsPath)) {
    Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
}
        
Write-Output "Deleting Teams uninstall registry key"
# Uninstall from Uninstall registry key UninstallString
$us = getUninstallString("Teams");
if ($us.Length -gt 0) {
    $us = ($us.Replace("/I", "/uninstall ") + " /quiet").Replace("  ", " ")
    $FilePath = ($us.Substring(0, $us.IndexOf(".exe") + 4).Trim())
    $ProcessArgs = ($us.Substring($us.IndexOf(".exe") + 5).Trim().replace("  ", " "))
    $proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
    $proc.WaitForExit()
}
            
Write-Output "Restart computer to complete teams uninstall"
            
Write-Host "Removing Bloatware"

foreach ($Bloat in $Bloatware) {
    Get-AppxPackage -allusers  "*$Bloat*" | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$Bloat*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    Write-Host "Trying to remove $Bloat."
}
            
#Find and remove installed bloatwares with DISM
$installed_bloatwares=DISM /Online /Get-ProvisionedAppxPackages |Where-Object{$_ -match "PackageName"}

foreach ($Bloat in $installed_bloatwares) {
$to_remove = $Bloat.substring(14) #Filter only the value of PackageName
DISM /Online /Remove-ProvisionedAppxPackage /PackageName:$to_remove
Write-Host "Removing $to_remove ."
}

Write-Host "======================================="
Write-Host "---   Finished Removing Bloatware   ---"
Write-Host "======================================="