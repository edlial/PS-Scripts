Update-MpSignature -UpdateSource MicrosoftUpdateServer
Start-Sleep 15
$Programs = @{ 
    'Access' ='MSACCESS.EXE'
    'Adobe Acrobat' = 'Acrobat.exe'
    'Chrome' = 'chrome.exe'
    'Edge' = 'msedge.exe'
    'Excel' = 'Excel.exe'
    'OneNote' = 'OneNote.exe'
    'Outlook' = 'OUTLOOK.EXE'
    'PowerPoint' = 'powerpnt.exe'
    'Publisher' = 'MSPUB.EXE'
    'Word' = 'Winword.exe'
 }
foreach( $p in $Programs.Keys ){
    $WShell = New-Object -comObject WScript.Shell
    $Shortcut = $WShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$p.lnk") 
    #create shortcut in desktop also
    $Shortcut2 = $WShell.CreateShortcut("C:\Users\Public\Desktop\$p.lnk")
    $Shortcut2 = $WShell.CreateShortcut("C:\Users\Pubblica\Desktop\$p.lnk")
    $Shortcut.TargetPath = [string](Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$($programs.$p)").'(default)'
    $Shortcut.save()
}
##Cisco Jabber
$fileToCheck = "C:\Program Files (x86)\Cisco Systems\Cisco Jabber\CiscoJabber.exe"
if (Test-Path $fileToCheck -PathType leaf)
{ $SourceFilePath = $fileToCheck
$ShortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Cisco Jabber.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save() }
Write-Output "Shortcuts created"
Exit 0