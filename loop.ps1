#create array of computers from above items
$computers = @('AMM01','PCAMM001','SUPPORT','ZOADM001','ZOADM002','ZOADM003','ZOAMB001','ZOAMB002','ZOAMB003','ZOAMB004','ZOAMB005','ZOAMB006','ZOAMB007','ZOAMB008','ZOAMB009','ZOAMB011','ZOAMB013','ZOAMB014','ZOAMB016','ZOAMB017','ZOAMB018','ZOAMB019','ZOAMB020','ZOBOP001','ZOBOP002','ZOBOP003','ZOBOP004','ZOBOP005','ZOBOP006','ZOBOP007','ZOBOP008','ZOBOP009','ZOBOPVM','ZODIR002','ZOHOS002','ZOHOS003','ZOLAB001','ZOLAB002','ZOLAB003','ZOLOG001','ZOLOG002','ZOLOG003','ZOLOG004','ZOLOG005','ZOLOG006','ZOLOG007','ZOLOG008','ZOPOL004','ZORAD001','ZORAD002','ZORAD003','ZORAD004','ZORAD005','ZORAD006','ZOREC001','ZOREC002','ZOREC003','ZOREC004','ZOREC005','ZOREC006','ZOREC007','ZOREC008','ZOREC009')

#loop through computers and ping them
foreach ($computer in $computers) {
    $ping = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if ($ping) {
        Write-Host "[ $computer ] is online" -ForegroundColor Green

        #test if enter-pssession works
        try {
            $session = Enter-PSSession -ComputerName $computer -ErrorAction SilentlyContinue
            if ($?) {
                #Write-Host "[ $computer ] Enter-PSSession works" -ForegroundColor Green
                #close session
                Exit-PSSession

                #run script on computer
                #Write-Host "[ $computer ] Copying script" -ForegroundColor Green
                
                #copy script via winrm to computer
                #Copy-Item –Path \\mecm\Microsoft365Apps\setup.exe –Destination 'C:\Program Files\5Q\' –ToSession (New-PSSession –ComputerName $computer) 
                #Copy-Item –Path \\mecm\Microsoft365Apps\A1.xml –Destination 'C:\Program Files\5Q\' –ToSession (New-PSSession –ComputerName $computer)

                #check adobe version
                #Write-Host "[ $computer ] Checking vlc version" -ForegroundColor Green
                $result = Invoke-Command -ComputerName $computer -ScriptBlock {  choco list --local-only | Select-String adobereader ; $installedApps = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, UninstallString | Where-Object { $_.DisplayName -ne $null } ;
                #get installed 64 bit applications
                $installedApps64 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, UninstallString | Where-Object { $_.DisplayName -ne $null } ;
                #combine the two
                $installedApps = $installedApps + $installedApps64 ;
                $installedApps | Select-String "Adobe Acrobat" ;
                }
                Write-Host $result

                #remove script from computer
                #  Write-Host "[ $computer ] Removing script" -ForegroundColor Green
                #  Remove-Item –Path 'C:\Program Files\5Q\setup.exe' –ToSession (New-PSSession –ComputerName $computer)
                #  Remove-Item –Path 'C:\Program Files\5Q\A1.xml' –ToSession (New-PSSession –ComputerName $computer)
                
            }
            else {
                Write-Host "[ $computer ] Enter-PSSession does not work" -ForegroundColor Yellow
            }
           
        }
        catch {
            Write-Host "[ $computer ] could not connect via enter-pssession" -ForegroundColor Red
        }
    }
    else {
        #color red
        Write-Host "[ $computer ] is offline" -ForegroundColor Red
    }
} 


#MYSQL


