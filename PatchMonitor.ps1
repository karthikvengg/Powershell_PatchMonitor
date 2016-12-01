$watcher = New-Object System.IO.FileSystemWatcher
#$location = "D:\Karthik\Builds\Patches"
$watcher.Path = $location
$watcher.Filter = "*.txt"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true 

$action = { $path = $Event.SourceEventArgs.FullPath
			$changeType = $Event.SourceEventArgs.ChangeType
			$source = Split-Path $path	
			Write-Host "`n"
			$bnum = Split-Path (Split-Path $path -Parent) -Leaf
			Write-Host "Preprocessing of patch execution started for build no: "$bnum
			Write-Host "Clearing content inside Input folder."
			Remove-Item -Path C:\Working\Input\* -Recurse -Force			
			Write-Host "Started copying patch files to Input folder."
			Copy-item  -Path $source\* -Destination C:\Working\Input -Recurse			
			Write-Host "Copy complete."
			Set-Location C:\Working
			Write-Host "Clearing content inside Output folder."
			Remove-Item -Path C:\Working\Output\* -Recurse -Force									
			$cmd ='python PatchPoster.py '+$bnum+' > PatchExecutionLog.txt'	
			Write-Host "Patch execution started."
			Write-Host "Please wait..."
			iex $cmd
			Write-Host "Execution Complete."
			
			$from_addr = ""
			$smtpServer = "" #Mail server IP
			Write-Host "Sending mail."
            $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer)            
			$emailMessage = New-Object System.Net.Mail.MailMessage
			$emailMessage.From = ""
			$emailMessage.To.Add( "" )
			$emailMessage.cc.Add( "" )
			$emailMessage.Subject = "Patch poster automation [Beta] "
			$emailMessage.IsBodyHtml = $true
			$emailMessage.Body = "<p>Execution completed for Integration build $bnum<p></br><p>**Automated mail**</p>"
            $smtp.Send($emailMessage)			
			Write-Host "Check 'C:\Working\PatchExecutionLog.txt' for Patch poster execution logs"					
			Write-Host "`n"
			Write-Host "Monitoring. Do not close the window!!"
		  }    
		  
Write-Host "`n"		  
Write-Host "Monitoring location: "$location". Do not close the window!!"
Register-ObjectEvent $watcher "Created" -Action $action
while ($true) {sleep 5}