Do{

$ID = Read-Host "Enter user ID"

If($ID -eq $Null -or $ID -eq ""){Write-Host "Please enter a user ID"}

}
Until($ID -ne $Null -or $ID -ne "")


$SID = (Get-ADUser $ID -Properties *).SID

$ID = $ID.ToUpper()

Try{Get-ADUser $ID}
Catch{

Write-Host "Invalid user ID..." -ForegroundColor Red

Pause

Exit

}

Write-Host "Monitor started for account $ID..." -ForegroundColor Cyan

$Time = Get-Date -Format T

$Counter = "0"

Do{

$Status = (Get-ADUser $ID -Properties *).LockedOut

If($Status -eq 'True'){

Write-Host "ACCOUNT FOR $ID LOCKED" -ForegroundColor Red

$PlayWav=New-Object System.Media.SoundPlayer
$PlayWav.SoundLocation=’C:\Windows\Media\Windows Pop-up Blocked.wav’
$PlayWav.playsync()

$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\slui.exe") 
$NotifyIcon.Text = "Lockout Monitor for $ID"
$NotifyIcon.Visible = $True

$NotifyIcon.BalloonTipTitle = "Lockout Monitor for $ID"
$NotifyIcon.BalloonTipText = "$ID account lockout" 
$NotifyIcon.ShowBalloonTip(30000)
$NotifyICon.Add_BalloonTipClicked{

Unlock-ADAccount -Identity $ID -Verbose

$NotifyIcon.Dispose()

}
$NotifyIcon.Visible = $True

Start-Sleep 15

$NotifyIcon.Dispose()

Write-Host "Resuming monitor..." -ForegroundColor Cyan

}

If($Status -ne 'True'){Write-Host "Account for $ID not locked" -ForegroundColor Green}

$Server = (Get-ADDomain | Select-Object -Property PDCEmulator).PDCEmulator
$1 = Get-Date
$2 = (Get-ADUser $ID -Properties * -Server $Server).LastBadPasswordAttempt
$Failure= (New-Timespan –Start $2 –End $1).TotalSeconds
If($Failure -lt 3){Write-Host "Recent login failure detected for $ID, $2" -ForegroundColor Yellow}

Start-Sleep 3

}

While($True)
