Add-Type -AssemblyName System.Windows.Forms

Function Global:Create_Credentials{

$ID = $UserTextbox.Text
$IDDomain = "$env:USERDOMAIN\$ID"
$Password = $PasswordTextbox.Text
$PasswordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force
$Global:Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $IDDomain, $PasswordSecure

Remove-Variable PasswordSecure -Force
Remove-Variable Password -Force

}

$ServiceUpdater = New-Object System.Windows.Forms.Form
$ServiceUpdater.ControlBox = $True
$ServiceUpdater.MaximizeBox = $False
$ServiceUpdater.MinimizeBox = $False
$ServiceUpdater.Text = "Service Logon Updater"
$ServiceUpdater.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$ServiceUpdater.Font = $Font
$ServiceUpdater.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
$ServiceUpdater.ClientSize = New-Object System.Drawing.Size(500, 420)

$UserTextLabel = New-Object "System.Windows.Forms.Label"
$UserTextLabel.Location = '10, 10'
$UserTextLabel.Text = "Auth Account"
$UserTextLabel.Size = '72, 23'
$ServiceUpdater.Controls.Add($UserTextLabel)

$ClearAuthButton = New-Object "System.Windows.Forms.Button"
$ClearAuthButton.Location = '82, 10'
$ClearAuthButton.Size = '35, 15'
$ClearAuthButton.Text = "Clear"
$ClearAuthButton.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
$ClearAuthButton.Add_click{

$UserTextbox.Clear()
$PasswordTextbox.Clear()

}
$ServiceUpdater.Controls.Add($ClearAuthButton)

$UserTextbox = New-Object "System.Windows.Forms.Textbox"
$UserTextbox.Location = '10, 38'
$UserTextbox.Size = '105, 10'
$ServiceUpdater.Controls.Add($UserTextbox)

$PasswordTextLabel = New-Object "System.Windows.Forms.LinkLabel"
$PasswordTextLabel.Location = '10, 67'
$PasswordTextLabel.Text = "Auth Password"
$PasswordTextLabel.Size = '105, 23'
$PasswordTextLabel.Add_click{$PasswordTextBox.Text | Set-Clipboard}
$ServiceUpdater.Controls.Add($PasswordTextLabel)

$PasswordTextbox = New-Object "System.Windows.Forms.Textbox"
$PasswordTextbox.Location = '10, 90'
$PasswordTextbox.Size = '105, 10'
$PasswordTextbox.UseSystemPasswordChar = $True
$ServiceUpdater.Controls.Add($PasswordTextbox)

$ComputerTextLabel = New-Object "System.Windows.Forms.Label"
$ComputerTextLabel.Location = '10, 123'
$ComputerTextLabel.Text = "Computer"
$ComputerTextLabel.Size = '55, 23'
$ServiceUpdater.Controls.Add($ComputerTextLabel)

$ClearComputerButton = New-Object "System.Windows.Forms.Button"
$ClearComputerButton.Location = '80, 123'
$ClearComputerButton.Size = '35, 15'
$ClearComputerButton.Text = "Clear"
$ClearComputerButton.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
$ClearComputerButton.Add_click{

$ServiceUpdater.Controls.Add($StartService)
$ServiceUpdater.Controls.Add($StopService)

$ComputerTextbox.Clear()
$ListBox.Items.Clear()
$ComputerTextbox.ReadOnly = $False

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

}
$ServiceUpdater.Controls.Add($ClearComputerButton)

$ComputerTextbox = New-Object "System.Windows.Forms.Textbox"
$ComputerTextbox.Location = '10, 150'
$ComputerTextbox.Size = '105, 23'
$ServiceUpdater.Controls.Add($ComputerTextbox)

$GetServicesButton = New-Object "System.Windows.Forms.Button"
$GetServicesButton.Location = '10, 180'
$GetServicesButton.Size = '70, 20'
$GetServicesButton.Text = "Services"
$GetServicesButton.Add_click{

Clear-Host

$ListBox.Items.Clear()

$ServiceUpdater.Controls.Add($StartService)
$ServiceUpdater.Controls.Add($StopService)

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = "Green"
$GetServicesButton.ForeColor = "White"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Global:Create_Credentials

$Computer = $ComputerTextbox.Text

If($Computer -eq $Null -or $Computer -eq ""){

[System.Windows.Forms.MessageBox]::Show("Computer name not entered.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

If(Test-Connection $Computer -Count 1 -Quiet){} else {

[System.Windows.Forms.MessageBox]::Show("$Computer not online, please check name or connectivity.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

$ServicesFind = Invoke-Command -ComputerName $Computer -ScriptBlock{(Get-Service | Select DisplayName).DisplayName} -Credential $Global:Credentials

$Services = $ServicesFind | Sort-Object

ForEach($Service in $Services){

[void] $ListBox.Items.Add($Service)

}

$ComputerTextbox.ReadOnly = $True

}
$ServiceUpdater.Controls.Add($GetServicesButton)

$GetIISAppPoolsButton = New-Object "System.Windows.Forms.Button"
$GetIISAppPoolsButton.Location = '83, 180'
$GetIISAppPoolsButton.Size = '27, 20'
$GetIISAppPoolsButton.Text = "IIS"
$GetIISAppPoolsButton.Add_click{

Clear-Host

$ListBox.Items.Clear()

$ServiceUpdater.Controls.Remove($StartService)
$ServiceUpdater.Controls.Remove($StopService)

$GetIISAppPoolsButton.BackColor = "Green"
$GetIISAppPoolsButton.ForeColor = "White"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Global:Create_Credentials

$Computer = $ComputerTextbox.Text

If($Computer -eq $Null -or $Computer -eq ""){

[System.Windows.Forms.MessageBox]::Show("Computer name not entered.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

If(Test-Connection $Computer -Count 1 -Quiet){} else {

[System.Windows.Forms.MessageBox]::Show("$Computer not online, please check name or connectivity.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

$IISRaw = Invoke-Command -ComputerName $Computer -ScriptBlock{

Import-Module WebAdministration -Force

(Get-ItemProperty IIS:\AppPools).Children

} -Credential $Global:Credentials

Write-Host $IISRaw

$IISAppPools = $IISRaw.Keys

ForEach($AppPool in $IISAppPools){[void] $ListBox.Items.Add($AppPool)}

Clear-Host

$ComputerTextbox.ReadOnly = $True

}
$ServiceUpdater.Controls.Add($GetIISAppPoolsButton)

$GetScheduledTaskButton = New-Object "System.Windows.Forms.Button"
$GetScheduledTaskButton.Location = '10, 203'
$GetScheduledTaskButton.Size = '100, 20'
$GetScheduledTaskButton.Text = "Scheduled Tasks"
$GetScheduledTaskButton.Add_click{

Clear-Host

$ListBox.Items.Clear()

$ServiceUpdater.Controls.Remove($StartService)
$ServiceUpdater.Controls.Remove($StopService)

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = "Green"
$GetScheduledTaskButton.ForeColor = "White"

Global:Create_Credentials

$Computer = $ComputerTextbox.Text

If($Computer -eq $Null -or $Computer -eq ""){

[System.Windows.Forms.MessageBox]::Show("Computer name not entered.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

If(Test-Connection $Computer -Count 1 -Quiet){} else {

[System.Windows.Forms.MessageBox]::Show("$Computer not online, please check name or connectivity.", 'Attention!', 'OK')

$GetIISAppPoolsButton.BackColor = ""
$GetIISAppPoolsButton.ForeColor = "Black"
$GetServicesButton.BackColor = ""
$GetServicesButton.ForeColor = "Black"
$GetScheduledTaskButton.BackColor = ""
$GetScheduledTaskButton.ForeColor = "Black"

Return

}

$ScheduledTaksRaw = Invoke-Command -ComputerName $Computer -ScriptBlock{(Get-ScheduledTask -TaskPath \).TaskName} -Credential $Global:Credentials

ForEach($Task in $ScheduledTaksRaw){[void] $ListBox.Items.Add($Task)}

Clear-Host

$ComputerTextbox.ReadOnly = $True

}
$ServiceUpdater.Controls.Add($GetScheduledTaskButton)

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location = New-Object System.Drawing.Point(142, 10)
$ListBox.Size = New-Object System.Drawing.Size(350, 350)
$ListBox.SelectionMode = 'MultiExtended'
$ServiceUpdater.Controls.Add($ListBox)

$ServiceUserTextLabel = New-Object "System.Windows.Forms.Label"
$ServiceUserTextLabel.Location = '10, 235'
$ServiceUserTextLabel.Text = "Account"
$ServiceUserTextLabel.Size = '60, 23'
$ServiceUpdater.Controls.Add($ServiceUserTextLabel)

$ClearAuthButton = New-Object "System.Windows.Forms.Button"
$ClearAuthButton.Location = '80, 235'
$ClearAuthButton.Size = '35, 15'
$ClearAuthButton.Text = "Clear"
$ClearAuthButton.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
$ClearAuthButton.Add_click{

$ServiceUserTextbox.Clear()
$ServicePasswordTextbox.Clear()

}
$ServiceUpdater.Controls.Add($ClearAuthButton)

$PreviousAccountsMenu = New-Object System.Windows.Forms.ContextMenuStrip
$PreviousAccountsMenu.ShowImageMargin = $True
$PreviousAccountsMenu.ShowItemToolTips = $True

$PreviousAccountsButton = New-Object "System.Windows.Forms.Button"
$PreviousAccountsButton.Location = '118, 260'
$PreviousAccountsButton.Size = '18, 23'
$PreviousAccountsButton.Text = "O"
$PreviousAccountsButton.Add_click{

$Cursor = [System.Windows.Forms.Cursor]::Position
$PreviousAccountsMenu.Show($Cursor)

}
$ServiceUpdater.Controls.Add($PreviousAccountsButton)

$ServiceUserTextbox = New-Object "System.Windows.Forms.Textbox"
$ServiceUserTextbox.Location = '10, 260'
$ServiceUserTextbox.Size = '105, 23'
$ServiceUpdater.Controls.Add($ServiceUserTextbox)

$ShowServicePasswordTextLabel = New-Object "System.Windows.Forms.LinkLabel"
$ShowServicePasswordTextLabel.Location = '10, 288'
$ShowServicePasswordTextLabel.Text = "Password"
$ShowServicePasswordTextLabel.Size = '60, 20'
$ShowServicePasswordTextLabel.Add_click{$ServicePasswordTextbox.Text | Set-Clipboard}
$ServiceUpdater.Controls.Add($ShowServicePasswordTextLabel)

$ServicePasswordTextbox = New-Object "System.Windows.Forms.MaskedTextbox"
$ServicePasswordTextbox.Location = '10, 310'
$ServicePasswordTextbox.Size = '105, 23'
$ServicePasswordTextbox.UseSystemPasswordChar = $True
$ServiceUpdater.Controls.Add($ServicePasswordTextbox)

$ServiceUserTextLabel = New-Object "System.Windows.Forms.Label"
$ServiceUserTextLabel.Location = '10, 235'
$ServiceUserTextLabel.Text = "Account"
$ServiceUserTextLabel.Size = '60, 23'
$ServiceUpdater.Controls.Add($ServiceUserTextLabel)

$UpdateServiceButton = New-Object "System.Windows.Forms.Button"
$UpdateServiceButton.Location = '10, 340'
$UpdateServiceButton.Size = '105, 43'
$UpdateServiceButton.Text = "Update Service Logon"
$UpdateServiceButton.ForeColor = "Black"
$UpdateServiceButton.BackColor = "Yellow"
$UpdateServiceButton.Add_click{

Clear-Host

If($ServiceUserTextbox.Text -eq ""){

[System.Windows.Forms.MessageBox]::Show("Account name not entered.", 'Attention!', 'OK')

Return

}

If($ServicePasswordTextbox.Text -eq ""){

$Continue = [System.Windows.Forms.MessageBox]::Show("Account password not entered. This action will only succeed if the account used is a default system account. Continue?", 'Attention!', 'YesNo')

If($Continue -eq 'Yes'){}
If($Continue -eq 'No'){Return}

}

Global:Create_Credentials

#########################

$AddToList = $ServiceUserTextbox.Text
$PreviousAccountsMenu.Items.Add($AddToList)
$CurrentList = ($PreviousAccountsMenu.Items).Text
$PreviousArray = New-Object System.Collections.ArrayList
ForEach($Item in $CurrentList){$PreviousArray.Add($Item)}
$PreviousAccountsMenu.Items.Clear()

ForEach($Item in $PreviousArray){

If($Item -ne "Clear Previous Accounts"){

[System.Windows.Forms.ToolStripItem]$PreviousAccounts = New-Object System.Windows.Forms.ToolStripMenuItem
$PreviousAccounts.Text = $Item
$PreviousAccounts.add_Click{

$ServiceUserTextbox.Text = $This.Text

$ImportButton.PerformClick()

}
$PreviousAccountsMenu.Items.Add($PreviousAccounts)

}

}

[System.Windows.Forms.ToolStripItem]$ClearPreviousAccounts = New-Object System.Windows.Forms.ToolStripMenuItem
$ClearPreviousAccounts.Text = "Clear Previous Accounts"
$ClearPreviousAccounts.ForeColor = "Red"
$ClearPreviousAccounts.add_Click{$PreviousAccountsMenu.Items.Clear()}
$PreviousAccountsMenu.Items.Add($ClearPreviousAccounts)

#########################

$ServiceUser = $ServiceUserTextbox.Text
$ServicePassword = $ServicePasswordTextbox.Text
$Computer = $ComputerTextbox.Text
$SelectedServices = $ListBox.SelectedItems

If($SelectedServices.Count -eq 0){

[System.Windows.Forms.MessageBox]::Show("Service(s) not selected", 'Attention!', 'OK')

Return

}

###########################################

If($GetIISAppPoolsButton.BackColor -eq "Green"){

ForEach($Service in $SelectedServices){

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $ServiceUser, $ServicePassword -ScriptBlock{

$Service = $Using:Service
$ServiceUser = $Using:ServiceUser
$ServicePassword = $Using:ServicePassword

Try{

Import-Module WebAdministration

Set-ItemProperty IIS:\AppPools\$Service -name ProcessModel -value @{userName=$ServiceUser;password=$ServicePassword;identitytype=3}

Write-Host "Identity for Application Pool ""$Service"" set to $ServiceUser" -ForegroundColor Green

}

Catch{Write-Host "Failed to set identity for Application Pool ""$Service"" to $ServiceUser" -ForegroundColor Yellow}

} -Credential $Global:Credentials

}

Return

}

If($GetScheduledTaskButton.BackColor -eq "Green"){

ForEach($Service in $SelectedServices){

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $ServiceUser, $ServicePassword -ScriptBlock{

$Service = $Using:Service
$ServiceUser = $Using:ServiceUser
$ServicePassword = $Using:ServicePassword

Set-ScheduledTask -TaskName $Service -User $ServiceUser -Password $ServicePassword -ErrorAction SilentlyContinue

$Attribute = "Run As User"

$Check = (schtasks.exe /query /s localhost  /V /FO CSV | ConvertFrom-Csv | Where { $_.TaskName -eq "\$Service" }).$Attribute

If($Check -eq $ServiceUser){Write-Host "Successfully set task ""$Service"" to run as $ServiceUser" -ForegroundColor Green} else {Write-Host "Failed to set tasks ""$Service"" to run as $ServiceUser" -ForegroundColor Yellow}

} -Credential $Global:Credentials

}

Return

}

If($GetServicesButton.BackColor -eq "Green"){

$SID = ((Get-ADuser $ServiceUser -Properties *).SID).Value

$Line = Invoke-Command -ComputerName $Computer -ArgumentList $Computer, $SID -ScriptBlock{

$SID = $Using:SID

SECEDIT /export /cfg "C:\Users\Public\export.inf"

$DB = "C:\Users\Public\db.sdb"
$Import = "C:\Users\Public\import.inf"
$Export = "C:\Users\Public\export.inf"

$Line = (Select-String $Export -Pattern "SeServiceLogonRight").Line

} -Credential $Global:Credentials

If($Line -match $SID){Write-Host "$User already has service logon access..." -ForegroundColor Green}

If($Line -notmatch $SID){$ServiceLogonAccessButton.PerformClick()}

###########################################

$StopService.PerformClick()

ForEach($Service in $SelectedServices){
$ServiceFinal = Invoke-Command -ComputerName $Computer -ArgumentList $Service -ScriptBlock{(Get-Service | Where {$_.DisplayName -eq $Using:Service}).Name} -Credential $Global:Credentials

$Change = Invoke-Command -ComputerName $Computer -ArgumentList $ServiceFinal, $ServiceUser, $ServicePassword, $Computer -ScriptBlock{

$Service = $Using:ServiceFinal
$Password = $Using:ServicePassword
If($Password -eq "" -or $Password -eq $Null){$User = "$Using:ServiceUser"}
If($Password -ne "" -or $Password -ne $Null){$User = "$env:USERDOMAIN\$Using:ServiceUser"}
$Computer = $Using:Computer

$ServiceCMD = Get-Service $Service
$ServiceWMI = Get-WmiObject Win32_Service -filter "name='$($ServiceCMD.Name)'"
$ServiceWMI.StopService()

If($Password -ne ""){
$ServiceWMI.Change(
$null,
$null,
$null,
$null,
$null,
$null,
$User,
$Password,
$null,
$null,
$null)}

If($Password -eq "" -or $Password -eq $Null){
$ServiceWMI.Change(
$null,
$null,
$null,
$null,
$null,
$null,
$User,
$null,
$null,
$null,
$null)}

$Success = ($ServiceWMI).StartName

} -Credential $Global:Credentials

}

$StartService.PerformClick()

Write-Host ""

Write-Host "Set service user logon operation complete..." -ForegroundColor Green

Write-Host ""

}

}
$ServiceUpdater.Controls.Add($UpdateServiceButton)

$LocalSystemButton = New-Object "System.Windows.Forms.Button"
$LocalSystemButton.Location = '10, 390'
$LocalSystemButton.Size = '105, 23'
$LocalSystemButton.Text = "Set Local System"
$LocalSystemButton.Add_click{

Clear-Host

Global:Create_Credentials

$Computer = $ComputerTextbox.Text

$SelectedServices = $ListBox.SelectedItems

$StopService.PerformClick()

ForEach($Service in $SelectedServices){

$ServiceFinal = Invoke-Command -ComputerName $Computer -ArgumentList $Service -ScriptBlock{(Get-Service | Where {$_.DisplayName -eq $Using:Service}).Name} -Credential $Global:Credentials

Invoke-Command -ComputerName $Computer -ArgumentList $ServiceFinal, $Computer -ScriptBlock{

$Service = $Using:ServiceFinal
$Computer = $Using:Computer

$ServiceCMD = Get-Service $Service
$ServiceWMI = Get-WmiObject Win32_Service -filter "name='$($ServiceCMD.Name)'"

$ServiceWMI.StopService()

sc.exe config "$using:ServiceFinal" obj="Localsystem"

$Success = ($ServiceWMI).StartName

If($Success -eq "$User"){Write-Host "Service $Service updated with logon account $User successfully on $Computer" -ForegroundColor Green}

Try{Start-Service $Service -ErrorAction Stop}
Catch [System.Management.Automation.ActionPreferenceStopException]{Write-Host "Service $Service failed to start on $Computer" -ForegroundColor Red}

$Name = (Get-WmiObject Win32_Service -filter "name='$($Service)'").Name
$State = (Get-WmiObject Win32_Service -filter "name='$($Service)'").State
$StartName = (Get-WmiObject Win32_Service -filter "name='$($Service)'").StartName
$StartMode = (Get-WmiObject Win32_Service -filter "name='$($Service)'").StartMode

Write-Host "Computer: $using:Computer"
Write-Host "Service: $Name"
If($State -eq "Stopped"){Write-Host "Staus: $State" -ForegroundColor Red}
If($State -eq "Running"){Write-Host "Staus: $State" -ForegroundColor Green}
Write-Host "Logon Account: $StartName"
If($StartMode -ne "Disabled"){Write-Host "Startup Type: $StartMode"}
If($StartMode -eq "Disabled"){Write-Host "Startup Type: $StartMode" -ForegroundColor Yellow}
Write-Host ""

} -Credential $Global:Credentials

}

$StartService.PerformClick()

Write-Host ""

Write-Host "Set local system operation complete..." -ForegroundColor Green

Write-Host ""

}
$ServiceUpdater.Controls.Add($LocalSystemButton)

$ServiceLogonAccessButton = New-Object "System.Windows.Forms.Button"
$ServiceLogonAccessButton.Location = '10, 11415'
$ServiceLogonAccessButton.Size = '105, 23'
$ServiceLogonAccessButton.Text = "Grant Service Logon"
$ServiceLogonAccessButton.Add_click{

Clear-Host

Global:Create_Credentials

$Computer = $ComputerTextbox.Text
$ServiceUser = $ServiceUserTextbox.Text

$SID = ((Get-ADuser $ServiceUser -Properties *).SID).Value

$ServiceUser = $ServiceUserTextbox.Text

Invoke-Command -ComputerName $Computer -ArgumentList $SID, $ServiceUser, $Computer -ScriptBlock{

$SID = $Using:SID
$User = $Using:ServiceUser
$Computer = $Using:Computer

$tempPath = [System.IO.Path]::GetTempPath()
$import = Join-Path -Path $tempPath -ChildPath "import.inf"
  if(Test-Path $import) { Remove-Item -Path $import -Force }
  $export = Join-Path -Path $tempPath -ChildPath "export.inf"
  if(Test-Path $export) { Remove-Item -Path $export -Force }
  $secedt = Join-Path -Path $tempPath -ChildPath "secedt.sdb"
  if(Test-Path $secedt) { Remove-Item -Path $secedt -Force }
  try {
    secedit /export /cfg $export
    $sids = (Select-String $export -Pattern "SeServiceLogonRight").Line
    foreach ($line in @("[Unicode]", "Unicode=yes", "[System Access]", "[Event Audit]", "[Registry Values]", "[Version]", "signature=`"`$CHICAGO$`"", "Revision=1", "[Profile Description]", "Description=GrantLogOnAsAService security template", "[Privilege Rights]", "$sids,*$sid")){
      Add-Content $import $line
    }
    secedit /import /db $secedt /cfg $import
    secedit /configure /db $secedt
    Remove-Item -Path $import -Force
    Remove-Item -Path $export -Force
    Remove-Item -Path $secedt -Force
  } catch {
    Write-Host ("Failed to grant SeServiceLogonRight to user account: {0} on host: {1}." -f $User, $Computer)
    $error[0]
  }
} -Credential $Global:Credentials

}
$ServiceUpdater.Controls.Add($ServiceLogonAccessButton)

$StartService = New-Object "System.Windows.Forms.Button"
$StartService.Location = '170, 360'
$StartService.Size = '85, 23'
$StartService.Text = "Start Service"
$StartService.Add_click{

Clear-Host

Global:Create_Credentials

$Computer = $ComputerTextbox.Text
$Services = $ListBox.SelectedItems

ForEach($Service in $Services){
$Service = Invoke-Command -ComputerName $Computer -ArgumentList $Service -ScriptBlock{(Get-Service | Where {$_.DisplayName -eq $Using:Service}).Name} -Credential $Global:Credentials

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $Computer -ScriptBlock{

Get-Service $Using:Service | Start-Service -ErrorAction SilentlyContinue

$Name = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").Name
$State = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").State
$StartName = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartName
$StartMode = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartMode

Write-Host "Computer: $using:Computer"
Write-Host "Service: $Name"
If($State -eq "Stopped"){Write-Host "Staus: $State" -ForegroundColor Red}
If($State -eq "Running"){Write-Host "Staus: $State" -ForegroundColor Green}
Write-Host "Logon Account: $StartName"
If($StartMode -ne "Disabled"){Write-Host "Startup Type: $StartMode"}
If($StartMode -eq "Disabled"){Write-Host "Startup Type: $StartMode" -ForegroundColor Yellow}
Write-Host ""


} -Credential $Global:Credentials

}

}
$ServiceUpdater.Controls.Add($StartService)

$StopService = New-Object "System.Windows.Forms.Button"
$StopService.Location = '270, 360'
$StopService.Size = '85, 23'
$StopService.Text = "Stop Service"
$StopService.Add_click{

Clear-Host

Global:Create_Credentials

$Computer = $ComputerTextbox.Text
$Services = $ListBox.SelectedItems

ForEach($Service in $Services){
$Service = Invoke-Command -ComputerName $Computer -ArgumentList $Service -ScriptBlock{(Get-Service | Where {$_.DisplayName -eq $Using:Service}).Name} -Credential $Global:Credentials

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $Computer -ScriptBlock{

Get-Service $Using:Service | Stop-Service -ErrorAction SilentlyContinue

$Name = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").Name
$State = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").State
$StartName = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartName
$StartMode = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartMode

Write-Host "Computer: $using:Computer"
Write-Host "Service: $Name"
If($State -eq "Stopped"){Write-Host "Staus: $State" -ForegroundColor Red}
If($State -eq "Running"){Write-Host "Staus: $State" -ForegroundColor Green}
Write-Host "Logon Account: $StartName"
If($StartMode -ne "Disabled"){Write-Host "Startup Type: $StartMode"}
If($StartMode -eq "Disabled"){Write-Host "Startup Type: $StartMode" -ForegroundColor Yellow}
Write-Host ""


} -Credential $Global:Credentials

}

}
$ServiceUpdater.Controls.Add($StopService)

$StatusService = New-Object "System.Windows.Forms.Button"
$StatusService.Location = '370, 360'
$StatusService.Size = '85, 23'
$StatusService.Text = "Service Status"
$StatusService.Add_click{

Clear-Host

Global:Create_Credentials

$Computer = $ComputerTextbox.Text
$Services = $ListBox.SelectedItems

If($GetIISAppPoolsButton.BackColor -eq "Green"){

ForEach($Service in $Services){

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $ServiceUser, $ServicePassword -ScriptBlock{

$Service = $Using:Service

Import-Module WebAdministration -Force

$Attributes = ((Get-ChildItem IIS:\AppPools | Where {$_.PSChildName -eq "$Service"}).ChildElements).Attributes 

$UserName = ($Attributes | Select-Object | Where {$_.Name -eq "userName"}).Value

$Password = ($Attributes | Select-Object | Where {$_.Name -eq "password"}).Value

Write-Host "IIS Application Pool: $Service"
Write-Host "Username: $UserName"
Write-Host "Password: $Password"

} -Credential $Global:Credentials

}

}
If($GetScheduledTaskButton.BackColor -eq "Green"){

ForEach($Service in $Services){

Invoke-Command -ComputerName $Computer -ArgumentList $Service, $ServiceUser, $ServicePassword -ScriptBlock{

$Service = $Using:Service

$Attribute = "Run As User"

$AttributeRunAs = "Run As User"
$AttributeNextRun = "Next Run Time"
$AttributeLastRun = "Last Run Time"
$AttributeLastResult = "Last Result"
$AttributeTaskRun = "Task To Run"
$AttributeStatus  = "Status"

$Task = schtasks.exe /query /s localhost  /V /FO CSV | ConvertFrom-Csv | Where {$_.TaskName -eq "\$Service"}

$RunAs = $Task.$AttributeRunAs
$NextRun = $Task.$AttributeNextRun
$LastRun = $Task.$AttributeLastRun
$RunResult = $Task.$AttributeLastResult
$TaskRun = $Task.$AttributeTaskRun
$Status = $Task.$AttributeStatus

Write-Host "Run As User: $RunAs"
Write-Host "Next Run Time: $NextRun"
Write-Host "Last Run Time: $LastRun"
Write-Host "Last Run Result: $RunResult"
Write-Host "Task To Run: $TaskRun"
Write-Host "Status: $Status"

} -Credential $Global:Credentials

}

}

If($GetServicesButton.BackColor -eq "Green"){

ForEach($Service in $Services){
$Service = Invoke-Command -ComputerName $Computer -ArgumentList $Service -ScriptBlock{(Get-Service | Where {$_.DisplayName -eq $Using:Service}).Name} -Credential $Global:Credentials

$Retrieve = Invoke-Command -ComputerName $Computer -ArgumentList $Service, $Computer -ScriptBlock{

$Name = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").Name
$State = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").State
$StartName = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartName
$StartMode = (Get-WmiObject Win32_Service -filter "name='$($Using:Service)'").StartMode

Write-Host "Computer: $using:Computer"
Write-Host "Service: $Name"
If($State -eq "Stopped"){Write-Host "Staus: $State" -ForegroundColor Red}
If($State -eq "Running"){Write-Host "Staus: $State" -ForegroundColor Green}
Write-Host "Logon Account: $StartName"
If($StartMode -ne "Disabled"){Write-Host "Startup Type: $StartMode"}
If($StartMode -eq "Disabled"){Write-Host "Startup Type: $StartMode" -ForegroundColor Yellow}
Write-Host ""

} -Credential $Global:Credentials

}}}
$ServiceUpdater.Controls.Add($StatusService)

$CompManagement = New-Object "System.Windows.Forms.Button"
$CompManagement.Location = '170, 390'
$CompManagement.Size = '120, 23'
$CompManagement.Text = "Test"
$CompManagement.Add_click{

}
$ServiceUpdater.Controls.Add($CompManagement)

[void]$ServiceUpdater.ShowDialog()

