If($env:homeshare -eq $Null){$env:homeshare = $env:USERPROFILE}

$FileExplorer = New-Object System.Windows.Forms.OpenFileDialog
$FileExplorer.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"
$Show = $FileExplorer.ShowDialog()
If ($Show -eq "Cancel"){Return}
If ($Show -eq "OK"){

$File = ($FileExplorer | Select FileName).FileName

$Text = Get-Content $File -Raw

}
	
$TextSecure = $Text | ConvertTo-SecureString -AsPlainText -Force

Add-Type -AssemblyName 'System.Web'
			
$Length = 37
$Numbers = 5
$Salt = [System.Web.Security.Membership]::GeneratePassword($Length, $Number)
$SaltBytes = [Text.Encoding]::UTF8.GetBytes($Salt)
			
$Length = 20
$Numbers = 5
$Text = [System.Web.Security.Membership]::GeneratePassword($Length, $Number)
$Iterations = 1000
$PassDerive = New-Object Security.Cryptography.Rfc2898DeriveBytes -ArgumentList @($Text, $saltBytes, $Iterations, 'SHA512')
			
$KeySize = 256
$Key = $PassDerive.GetBytes($KeySize / 8)
			
Try{ 

$Key | Out-File "$env:homeshare\Desktop\Key.txt" -Force

Write-Host "Key file successfully created as $env:homeshare\Desktop\Key.txt..." -ForegroundColor Green

}

Catch{

Write-Host "Unable to create key file, aborting operation..." -ForegroundColor Red

Return

}  

Try{

$TextSecure | ConvertFrom-SecureString -Key $Key | Out-File "$env:homeshare\Desktop\File_Hash.txt" -ErrorAction SilentlyContinue

Write-Host "Hashed text file successfully created as $env:homeshare\Desktop\File_Hash.txt..." -ForegroundColor Green

}

Catch{

Write-Host "Unable to create file, aborting operation..." -ForegroundColor Red

Return

}  

$PromptDelete = Read-Host "Delete original file? [Y/N]"
If($PromptDelete -eq 'Y'){Remove-Item $File -Force}
If($PromptDelete -eq 'N'){}

Get-Variable | Remove-Variable -Force -ErrorAction SilentlyContinue

