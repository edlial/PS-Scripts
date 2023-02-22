$BingKey = "AqgqvnV6w1s7qAAj-ChRaMZDUQsgebRYUcZuDYtiJd844coO1vy2L1DrzbyTibW2"
$IPInfo = Invoke-RestMethod http://ipinfo.io/json
$Location = $IPInfo.loc
#$Country = $IPInfo.country
$City = $IPInfo.City
$BingTimeZoneURL = “http://dev.virtualearth.net/REST/v1/TimeZone/$Location” + “?key=$BingKey”
$ResultTZ = Invoke-RestMethod $BingTimeZoneURL
$WindowsTZ = $ResultTZ.resourceSets.resources.timeZone.windowsTimeZoneId
If (![string]::IsNullOrEmpty($WindowsTZ))
{
Get-TimeZone -Name $WindowsTZ
Set-TimeZone -Name $WindowsTZ
}
Write-Output "City is $City and time zone is set to $WindowsTZ!"
exit 0