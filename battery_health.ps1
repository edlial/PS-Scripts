#**************************** Part to fill ************************************
# Log analytics part
$CustomerId = "6c1b7c97-5488-4f5d-b036-32ffd0831458"
$SharedKey = '+SCl1T8PcJlgm+2dervC5K7aI1F5dDRV6BJ/QhJEDPn5h/5uVUqRWLJr9Ni9fC82VentajDwrDZDgkFqVjGriw=='
$LogType = "BatteryHealthReport" # Custom log to create in lo Analytics
$TimeStampField = "" # let to blank
#*******************************************************************************

# Log analytics functions
# More info there: https://docs.microsoft.com/en-us/azure/azure-monitor/logs/data-collector-api
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}
# Create the function to create and post the request
# More info there: https://docs.microsoft.com/en-us/azure/azure-monitor/logs/data-collector-api
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode
}

# Getting info from device and user
$Current_User_Profile = Get-ChildItem Registry::\HKEY_USERS | Where-Object { Test-Path "$($_.pspath)\Volatile Environment" } | ForEach-Object { (Get-ItemProperty "$($_.pspath)\Volatile Environment").USERPROFILE }
$Username = $Current_User_Profile.split("\")[2]		
$FQDN = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$OS = (Get-WmiObject -class Win32_OperatingSystem).Caption
$OSBuild = [System.Environment]::OSVersion.Version.Build
$DiskCFreeSpace = [Math]::Floor(((Get-PSDrive C).Free /[Math]::Pow(2, 30)*10)) /10
$totalSpace = ((Get-PSDrive C).Used + (Get-PSDrive C).Free)/(1024*1024*1024)
$DiskCTotalSpace = [Math]::Floor($totalSpace*10) / 10


$WMI_computersystem = Get-WmiObject win32_computersystem
$Manufacturer = $WMI_computersystem.manufacturer
If($Manufacturer -eq "lenovo")
	{
		$Get_Current_Model = $WMI_computersystem.SystemFamily.split(" ")[1]			
	}
Else
	{
		$Get_Current_Model = $WMI_computersystem.Model		
	}


#Function CheckBatteryHealth 
#{
	# Check for presence of battery and check where present
	If (Get-WmiObject win32_battery) {
		# Check machine type and other info
		[string]$SerialNumber = (Get-WmiObject win32_bios).SerialNumber
		
		# Maximum Acceptable Health Perentage
		$MinHealth = "40"

        # Multiple Battery handling
        $BatteryInstances = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryStatus" | Select-Object -ExpandProperty InstanceName
		
        ForEach($BatteryInstance in $BatteryInstances){

            # Set Variables for health check

            $BatteryDesignSpec = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryStaticData" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object -ExpandProperty DesignedCapacity
            $BatteryFullCharge = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryFullChargedCapacity" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object -ExpandProperty FullChargedCapacity

            # Fall back WMI class for Microsoft Surface devices
            if ($BatteryDesignSpec -eq $null -or $BatteryFullCharge -eq $null -and ((Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty Manufacturer) -match "Microsoft")) {
	
                # Attempt to call WMI provider
	            if (Get-WmiObject -Class MSBatteryClass -Namespace "ROOT\WMI") {
		            $MSBatteryInfo = Get-WmiObject -Class MSBatteryClass -Namespace "root\wmi" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object FullChargedCapacity, DesignedCapacity
		
		            # Set Variables for health check
		            $BatteryDesignSpec = $MSBatteryInfo.DesignedCapacity
		            $BatteryFullCharge = $MSBatteryInfo.FullChargedCapacity
	            }
            }
		
		    if ($BatteryDesignSpec -gt $null -and $BatteryFullCharge -gt $null) {
			    # Determine battery replacement required
			    [int]$CurrentHealth = ($BatteryFullCharge/$BatteryDesignSpec) * 100
			    if ($CurrentHealth -le $MinHealth) {
				    $ReplaceBattery = $true
				
				    # Generate Battery Report
				    $ReportingPath = Join-Path -Path $env:SystemDrive -ChildPath "Reports"
				    if (-not (Test-Path -Path $ReportingPath)) {
					    New-Item -Path $ReportingPath -ItemType Dir | Out-Null
				    }
				    $ReportOutput = Join-Path -Path $ReportingPath -ChildPath $('\Battery-Report-' + $SerialNumber + '.html')
				
				    # Run Windows battery health report
				    Start-Process PowerCfg.exe -ArgumentList "/BatteryReport /OutPut $ReportOutput" -Wait -WindowStyle Hidden
				
				    # Output replacement message and flag for remediation step
				    Write-Output "Battery replacement required: $CurrentHealth%"
				    exit 1
				
			    } else {
				    # Output replacement not required values
				    $ReplaceBattery = $false
				    Write-Output "Battery status: $($CurrentHealth)%"
				    # Not exiting here so that second battery can be checked
			    }
		    } else {
			# Output battery not present
			Write-Output "Battery not present."
			exit 0
		    }
            }
	    } else {
        # Output battery value condition check error
        Write-Output "Unable to obtain battery info from WMI."
        exit 0
    }
#}
#CheckBatteryHealth
# Creating the object to send to Log Analytics custom logs
$Properties = [Ordered] @{
    "ComputerName"        = $FQDN
    "Username"            = $Username
    "OperatingSystem"     = $OS
    "OSBuild"             = $OSBuild
    "Manufacturer"        = $Manufacturer 
    "Model"               = $Get_Current_Model
    "DriveCFreeSpace"     = $DiskCFreeSpace
    "DriveCTotalSpace"    = $DiskCTotalSpace 
	"BatteryHealth"       = $CurrentHealth
	}
$BatteryHealthResult = New-Object -TypeName "PSObject" -Property $Properties

$BatteryHealthResultJson = $BatteryHealthResult | ConvertTo-Json
$params = @{
    CustomerId = $customerId
    SharedKey  = $sharedKey
    Body       = ([System.Text.Encoding]::UTF8.GetBytes($BatteryHealthResultJson))
    LogType    = $LogType 
}
$LogResponse = Post-LogAnalyticsData @params
	
If($Exit_Status -eq 1)
	{
		EXIT 1
	}
Else
	{
		EXIT 0
	}	