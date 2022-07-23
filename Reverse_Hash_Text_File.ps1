If($env:homeshare -eq $Null){$env:homeshare = $env:USERPROFILE}

Write-Host "Select hashed text file" -ForegroundColor Yellow

$FileExplorer = New-Object System.Windows.Forms.OpenFileDialog
$FileExplorer.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"
$Show = $FileExplorer.ShowDialog()
If ($Show -eq "Cancel"){Return}
If ($Show -eq "OK"){

$FileText = ($FileExplorer | Select FileName).FileName

$SavedText = Get-Content $FileText

}

Write-Host "Select key file" -ForegroundColor Yellow

$FileExplorer = New-Object System.Windows.Forms.OpenFileDialog
$FileExplorer.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"
$Show = $FileExplorer.ShowDialog()
If ($Show -eq "Cancel"){Exit}
If ($Show -eq "OK"){

$FileKey = ($FileExplorer | Select FileName).FileName

$Key = Get-Content $FileKey

}

Try{

$Hash = [String]$SavedText | ConvertTo-SecureString -Key $Key

$Text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($Hash))))

$Text | Out-File "$env:homeshare\Desktop\File_Unhash.txt" -Force 

Write-Host "$FileText successfully converted and saved to desktop as $env:homeshare\Desktop\File_Unhash.txt..." -ForegroundColor Green

}

Catch{

Write-Host "Unable to convert $File, aborting operation..." -ForegroundColor Red

Return

}  

Get-Variable | Remove-Variable -Force -ErrorAction SilentlyContinue