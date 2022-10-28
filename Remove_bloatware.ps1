$Bloatware = @(
    #Unnecessary Windows 10 AppX Apps

    "2FE3CB00.PicsArt-PhotoStudio"
    "3DBuilder"
    "46928bounde.EclipseManager"
    "4DF9E0F8.Netflix"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "6Wunderkinder.Wunderlist"
    "7EE7776C.LinkedInforWindows"
    "89006A2E.AutodeskSketchBook"
    "9E2F88E3.Twitter"
    "A278AB0D.DisneyMagicKingdoms"
    "A278AB0D.MarchofEmpires"
    "ACGMediaPlayer"
    "ActiproSoftwareLLC"
    "ActiproSoftwareLLC.562882FEEB491"
    "AdobePhotoshopExpress"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Advertising"
    "AppConnector"
    "BingFinance"
    "BingFoodAndDrink"
    "BingHealthAndFitness"
    "BingNews"
    "BingSports"
    "BingTranslator"
    "BingTravel"
    "BingWeather"
    "BubbleWitch3Saga"
    "CAF9E577.Plex"
    "CandyCrush"
    "ClearChannelRadioDigital.iHeartRadio"
    "CommsPhone"
    "ConnectivityStore"
    "D52A8D61.FarmVille2CountryEscape"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Dolby"
    "DolbyLaboratories.DolbyAccess"
    "Drawboard.DrawboardPDF"
    "Duolingo-LearnLanguagesforFree"
    "EclipseManager"
    "Facebook"
    "Facebook.Facebook"
    "Fitbit.FitbitCoach"
    "flaregamesGmbH.RoyalRevolt2"
    "Flipboard"
    "Flipboard.Flipboard"
    "GAMELOFTSA.Asphalt8Airborne"
    "GamingServices"
    "GetHelp"
    "Getstarted"
    "HiddenCity"
    "HiddenCityMysteryofShadows"
    "HotspotShieldFreeVPN"
    "HPDesktopSupportUtilities"
    "HPEasyClean"
    "HPJumpStarts"
    "HPPCHardwareDiagnosticsWindows"
    "HPPowerManager"
    "HPPrivacySettings"
    "HPQuickDrop"
    "HPQuickTouch"
    "HPSupportAssistant"
    "HPSureShieldAI"
    "HPSystemInformation"
    "HPWorkWell"
    "Hulu"
    "KeeperSecurityInc.Keeper"
    "king.com."
    "king.com.BubbleWitch3Saga"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "Lens"
    "LinkedInforWindows"
    "Messaging"
    "Microsoft3DViewer"
    "MicrosoftOfficeHub"
    "MicrosoftSolitaireCollection"
    "MicrosoftStickyNotes"
    "Minecraft"
    "MinecraftUWP"
    "MixedReality.Portal"
    "MSPaint"
    "myHP"
    "Netflix"
    "NetworkSpeedTest"
    "News"
    "NORDCURRENT.COOKINGFEVER"
    "Office.Lens"
    "Office.OneNote"
    "Office.Sway"
    "Office.Todo.List"
    "OneCalendar"
    "OneConnect"
    "OneNote"
    "PandoraMediaInc"
    "PandoraMediaInc.29680B314EFC2"
    "People"
    "Playtika.CaesarsSlotsFreeCasino"
    "Print3D"
    "RemoteDesktop"
    "Royal Revolt"
    "ScreenSketch"
    "ShazamEntertainmentLtd.Shazam"
    "SkypeApp"
    "Speed Test"
    "Spotify"
    "SpotifyAB.SpotifyMusic"
    "StorePurchaseApp"
    "Sway"
    "TCUI"
    "TheNewYorkTimes.NYTCrossword"
    "ThumbmunkeysLtd.PhototasticCollage"
    "Todos"
    "TuneIn.TuneInRadio"
    "Twitter"
    "Viber"
    "Wallet"
    "Whiteboard"
    "Windows.Photos"
    "WindowsAlarms"
    "WindowsCamera"
    "windowscommunicationsapps"
    "WindowsFeedbackHub"
    "WindowsMaps"
    "WindowsPhone"
    "WindowsSoundRecorder"
    "WinZipComputing.WinZipUniversal"
    "Wunderlist"
    "Xbox.TCUI"
    "XboxApp"
    "XboxGameCallableUI"
    "XboxGameOverlay"
    "XboxGamingOverlay"
    "XboxIdentityProvider"
    "XboxSpeechToTextOverlay"
    "XINGAG.XING"
    "YourPhone"
    "ZuneMusic"
    "ZuneVideo"
    #"WindowsCalculator"
    #"WindowsReadingList"
    #"WindowsStore"
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
$installed_bloatwares = DISM /Online /Get-ProvisionedAppxPackages | Where-Object { $_ -match "PackageName" }

foreach ($Bloat in $installed_bloatwares) {
    $to_remove = $Bloat.substring(14) #Filter only the value of PackageName
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:$to_remove
    Write-Host "Removing $to_remove ."
}

Write-Host "======================================="
Write-Host "---   Finished Removing Bloatware   ---"
Write-Host "======================================="