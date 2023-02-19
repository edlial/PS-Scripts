Invoke-Command -cn mgmt,veeam,support,jlabbroker,paxera-ultima02,paxera-pacs02,sql01,dc-01,paxera-pacs01,paxera-brokerwl,dc-02,paxera-ultima01,fs01,paxera-database -ScriptBlock { 
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x {65A35679-0C08-4C9A-9AC3-46417F198653} /qn REBOOT=ReallySuppress" -Wait 
}
     
\\skzkm.local\NETLOGON\VMware-tools-12.1.5-20735119-x86_64.exe