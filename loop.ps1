

#create array of computers from above items
$computers = @('zoadm002', 'labospedale04', 'zoamb019', 'zoamb005', 'zolog006', 'zoamb006', 'ambulatorio02', 'zoamb003', 'zolog002', 'zobop004', 'zolog005', 'zorec003', 'zorec006', 'zohos002', 'zolab002', 'zolog007', 'zoamb013', 'desktop-pq1qo1f', 'zorec007', 'amm01', 'zoamb007', 'zorad006', 'zorad005', 'zoamb008', 'zorec005', 'pcamm001', 'zorec002', 'labospedale02', 'zodir002', 'zobop001', 'zoadm001', 'zoamb018', 'zorad001', 'zorad003', 'zolog008', 'zorec001', 'pcosp6', 'zolab003', 'zoamb001', 'magazzinoosp', 'zorec004', 'zorec008', 'zolog001', 'zoamb014', 'zolab001', 'pcosp05', 'zolog003', 'zorad004', 'labospedale03', 'zoamb011', 'labospedale', 'zobop003', 'zoamb017', 'zoamb002', 'zohos003', 'zobop002', 'labistologia')

#loop through computers and ping them
foreach ($computer in $computers) {
    $ping = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if ($ping) {
        Write-Host "[ $computer ] is online" -ForegroundColor Green

        #test if enter-pssession works
        try {
            $session = Enter-PSSession -ComputerName $computer -ErrorAction SilentlyContinue
            if ($?) {
                Write-Host "[ $computer ] Enter-PSSession works" -ForegroundColor Green
                #close session
                Exit-PSSession

                #run script on computer
                #Write-Host "[ $computer ] Copying script" -ForegroundColor Green
                
                #copy script via winrm to computer
                #Copy-Item –Path \\mecm\Microsoft365Apps\setup.exe –Destination 'C:\Program Files\5Q\' –ToSession (New-PSSession –ComputerName $computer) 
                #Copy-Item –Path \\mecm\Microsoft365Apps\A1.xml –Destination 'C:\Program Files\5Q\' –ToSession (New-PSSession –ComputerName $computer)

                #run script on computer and wait for it to finish
                #Invoke-Command -ComputerName $computer -ScriptBlock {  cd 'C:\Program Files\5Q\' ; .\setup.exe /configure .\A1.xml }

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