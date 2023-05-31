#disable Intel® Arc™ Control in startup
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Intel® Arc™ Control" -Value 0 -Type DWord