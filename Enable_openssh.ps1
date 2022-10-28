
#Install Open-SSH Server
Get-WindowsCapability -Online | Where-Object Name -like ‘OpenSSH.Server*’ | Add-WindowsCapability –Online
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd

#Add public key of skzkm\\e.zaganjori.ext to administrators_authorized_keys
Add-Content C:\ProgramData\ssh\administrators_authorized_keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCWuQb/ebWLKMHjZjcyEZpi7OuJWFzPD3IQlsyJZxvxn0UiDdl36RnK8YiftQ0GQVMbvEpZhPqwWHBNorguVMKxzZz08+i6RNViJyo7snTPs4djOqH2uSP5XNvryDiumapJDFxq9qAN9Q+Oj7hPXxgIQKwUeAcYpkVpa9oIi8OSI1e7OAotJKRs5ivFtqjzlXNr9uVIo44CCLYyHUAXSRrYZ+TsadbhYZ1gk+fRwdne/xuuO4CV6CeXpk0zdQKt4Z2pBYh8rWGDqWhn47cqQhDPbFD16df9xhHZncfL2fRyckGDk4+rJ/ZCMt99+IuYLIkTo80Q80k3xaDhbkns+HBNKFqky7TjirZVw+z+cEaxQKTI9HbYbJS1YDHXqyR9F2YGmUKgvcSgJZQBjJzj/v8+cutG0NfKufQrTYX9U3Y9fC9WCg2QE58FWPl82jpawkbyNxm3rMe4pqW4RhbSN2CiS1nQYVLpkB8uHbetVML567rifTCzPTCxKp+zvsna480= e.zaganjori.ext@skzkm.local@monitoring"

#Set the correct permissions for administrators_authorized_keys
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl

#Set PowerShell as default in OpenSSH
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "/c" -PropertyType String -Force


#Enable port 22 in Firewall
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

Restart-Service sshd