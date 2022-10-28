#


$isUpgradeSuccess = $false
try {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-command winget upgrade --all  | Out-Host" -Wait -WindowStyle Normal
    $isUpgradeSuccess = $true
}
catch [System.InvalidOperationException] {
    Write-Warning "Allow Yes on User Access Control to Upgrade"
}
catch {
    Write-Error $_.Exception
}

$result = if ($isUpgradeSuccess) { "Upgrade Done" } else { "Upgrade was not succesful" }
$result

# #Uninstall
# :Attempt Uninstalls
# echo product where "name like 'TeamViewer%%'" call uninstall /nointeractive|wmic && shutdown /a
# "%programfiles(x86)%\TeamViewer\uninstall.exe" /S
# "%programfiles%\TeamViewer\uninstall.exe" /S

# $TeamViewerGUID = Get-WmiObject win32_Product
# if ($TeamViewerGUID.identifyingnumber -match "{2DCBADA6-474A-4EB4-BC2B-C379C7D53F26}")
# {
#   msiexec.exe /X "{2DCBADA6-474A-4EB4-BC2B-C379C7D53F26}" /qn /norestart
# }


# if ($TeamViewerGUID.identifyingnumber -notmatch "{2DCBADA6-474A-4EB4-BC2B-C379C7D53F26}")
# {
#     taskkill /im TeamViewer.exe /t /f
#     Start-Sleep -Seconds 30
#     msiexec.exe /X "{23170F69-40C1-2702-2201-000001000000}" /qn /norestart
# }

# msiexec.exe /X "{23170F69-40C1-2702-2201-000001000000}" /qn /norestart