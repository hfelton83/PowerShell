Add-Type -Assembly System.Windows.Forms

$MasterURL = ""

If($MasterURL -eq ""){$MasterURL = Read-Host "Please enter CyberArk PVWA website URL"}

$TestURL = $MasterURL -replace "https://",""

If(Test-Connection $TestURL -Count 1 -Quiet -ErrorAction SilentlyContinue){} else {

Write-Host "Invalid CyberArk PVWA URL entered, please verify..." -ForegroundColo Red

Pause

Exit

}

Function CyberArk-Logon
{

$AccountLogin = Read-Host "Please enter your CyberArk login ID"
$Global:LoginPass = $AccountLogin
$username = $AccountLogin
$Token = Read-Host "Enter RSA passcode" -AsSecureString
$securePassword = $Token
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword

$LogonURL = "$MasterURL/PasswordVault/api/Auth/radius/Logon"

$BodyParameters = @{Username = $Credentials.Username; Password = ($Credentials.GetNetworkCredential().Password)} | ConvertTo-JSON

Try

{
    
$Session = Invoke-RestMethod -Uri $LogonURL -Method POST -ContentType "application/json" -Body $BodyParameters -ErrorVariable LogonError
    
}

Catch

{

$StatusCode =  $_.Exception.Response.StatusCode.value__
$StatusDescription =  $_.Exception.Response.StatusDescription
$StatusMessage = $_.Exception.Message

If($StatusCode -eq '401'){Write-Host "Username or password not entered, please try again...." -ForegroundColor Red}
If($StatusCode -eq '403'){Write-Host "Invalid username or password, please try again..." -ForegroundColor Red}
If($StatusCode -eq '404'){Write-Host "CyberArk site is not available at this time..." -ForegroundColor Red}
If($StatusCode -ne '404' -and $StatusCode -ne '403' -and $StatusCode -ne '401')

{

    Write-Host $StatusCode -ForegroundColor Yellow
    Write-Host $StatusDescription -ForegroundColor Yellow
    Write-Host $StatusMessage -ForegroundColor Yellow

}

}}

Function CyberArk-Logoff 
{
	

$URLLogoff = "$MasterURL/PasswordVault/api/Auth/Logoff"
	

$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
Invoke-RestMethod -Uri $URLLogoff -Method POST -ContentType "application/json" -Header $HeaderParameters

Get-Variable Session | Remove-Variable -Force -ErrorAction SilentlyContinue

Clear-Host

}

Function CyberArk-AddAccount 
{

Write-Host ""

Write-Host "Gathering account details..." -ForegroundColor Cyan

Write-Host ""

$Username = Read-Host "Please enter a username"
$Address = Read-Host "Please enter an address"
$Password = Read-Host "Please enter the current account password"
$PlatformID = Read-Host "Please enter the platform ID"
$Safe = Read-Host "Please enter the safe name"

$XML="{
  ""name"": ""Database-$PlatformID-$UserName"",
  ""address"": ""$Address"",
  ""userName"": ""$Username"",
  ""platformId"": ""$PlatformID"",
  ""safeName"": ""$Safe"",
  ""secretType"": ""password"",
  ""secret"": ""$Password"",
  ""platformAccountProperties"":  {
                                    ""Database"":  ""$Address""
                                  },
  ""secretManagement"": {
    ""automaticManagementEnabled"": true
         }
}"

Write-Host ""

Write-Host "ATTENTION: New account for $Username will be created in CyberArk with the below properties..." -ForegroundColor Cyan

Write-Host ""

Write-Host $XML -ForegroundColor Yellow

Write-Host ""

Do{

$Continue = Read-Host "Continue? [Y/N]"
If($Continue -ne 'Y' -and $Continue -ne 'N'){Write-Host "Invalid selection..." -ForegroundColor Yellow}
}

Until($Continue -eq 'Y' -or $Continue -eq 'N')

If($Continue -eq 'N'){

Write-Host "Aborting operation..." -ForegroundColor Yellow

Pause

Exit

}

$URLAddAccount = "$MasterURL/PasswordVault/api/Accounts"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
Try{

Invoke-RestMethod -Uri $URLAddAccount -Method POST -ContentType "application/json" -Headers $HeaderParameters -Body $XML -ErrorVariable LogonError

}

Catch

{

$StatusCode =  $_.Exception.Response.StatusCode.value__
$StatusDescription =  $_.Exception.Response.StatusDescription
$StatusMessage = $_.Exception.Message

If($StatusCode -eq '400'){Write-Host "Invalid data sent, property in body may not exist. " -ForegroundColor Yellow}
If($StatusCode -eq '401'){Write-Host "Username or password not entered, please try again." -ForegroundColor Yellow}
If($StatusCode -eq '403'){Write-Host "Invalid username or password, please try again." -ForegroundColor Yellow}
If($StatusCode -eq '404'){Write-Host "CyberArk site is not available at this time." -ForegroundColor Yellow}
If($StatusCode -eq '409'){Write-Host "Duplicate account exists in CyberArk, unable to proceed with account creation..." -ForegroundColor Yellow}
If($StatusCode -ne '404' -and $StatusCode -ne '403' -and $StatusCode -ne '401' -and $StatusCode -ne '400' -and $StatusCode -ne '409'){

    Write-Host $StatusCode -ForegroundColor Yellow
    Write-Host $StatusDescription -ForegroundColor Yellow
    Write-Host $StatusMessage -ForegroundColor Yellow

}}

Pause

Menu

}

Function CyberArk-DeleteAccount 
{

$Message = [System.Windows.Forms.MessageBox]::Show("This will delete accounts permanently from CyberArk. Continue?", 'Attention!', 'YesNo')

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
Try{$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters}

Catch

{
Write-Host "Unable to find account $Account in Cyberark..." -ForegroundColor Red
Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
Write-Host "Response:" $_.Exception.Message
Menu

}

If($AccountResult.count -eq "0"){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"
	
$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountResult}
If($AccountResult.userName -eq "$Account"){

$AccountID = $AccountResult.id

$Found = "True"}

If($Found -ne "True"){$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')}

Remove-Variable Found -Force -ErrorAction SilentlyContinue


$Confirm = $Message = [System.Windows.Forms.MessageBox]::Show("Please confirm deletion of $Account in CyberArk", 'Attention!', 'YesNo')

If($Confirm -eq 'No'){Menu}

Try{

Invoke-RestMethod -Uri $URLGetExactAccount -Method DELETE -ContentType "application/json" -Headers $HeaderParameters
$Message = [System.Windows.Forms.MessageBox]::Show("$Account successfully deleted in CyberArk", 'Attention!', 'OK')

}
Catch{$Message = [System.Windows.Forms.MessageBox]::Show("Unable to delete account $Account in CyberArk", 'Attention!', 'OK')}

}

Menu

}

Function CyberArk-BulkAddAccount 
{

Add-Type -Assembly System.Windows.Forms

New-Item "$env:homeshare\Desktop\Import.csv" -Force
Set-Content "$env:homeshare\Desktop\Import.csv" 'Address,Username,Password,Safe,Platform' -Force

$Message = [System.Windows.Forms.MessageBox]::Show("Required CSV format added to your desktop as Import.csv. Please ensure the selected .CSV file is in this format.", 'Attention!', 'OK')

Do{

$FileExplorer = New-Object System.Windows.Forms.OpenFileDialog
$FileExplorer.Filter = "csv files (*.csv)|*.csv|All files (*.*)|*.*"
$Show = $FileExplorer.ShowDialog()
If ($Show -eq "OK"){$Temp_CSV = ($FileExplorer | Select FileName).FileName}

Write-Host "Using file $Temp_CSV for CyberArk account import...." -ForegroundColor Green
$Continue = Read-Host "Continue? [Y/N]"
If($Continue -ne 'Y' -and $Continue -ne 'N'){Write-Host "Invalid selection..." -ForegroundColor Yellow}
}
Until($Continue -eq 'Y' -or $Continue -eq 'N')

If($Continue -eq 'N'){

Write-Host "Aborting operation..." -ForegroundColor Yellow

Menu

}

If($Continue -eq 'Y'){$CSV = Import-CSV -Path $Temp_CSV}

$Count = $CSV.Count

$Continue = $Message = [System.Windows.Forms.MessageBox]::Show("$Count accounts will be imported into CyberArk if you proceed! Cotinue?", 'Attention!', 'YesNo')
If($Continue -eq 'No'){Menu}

Do{
$Continue = Read-Host "Continue? [Y/N]"
If($Continue -ne 'Y' -and $Continue -ne 'N'){Write-Host "Invalid selection..." -ForegroundColor Yellow}
}
Until($Continue -eq 'Y' -or $Continue -eq 'N')

If($Continue -eq 'N'){

Write-Host "Aborting operation..." -ForegroundColor Yellow

Menu

}

#################################################

$URLAddAccount = "$MasterURL/PasswordVault/api/Accounts"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
ForEach($Account in $CSV){

$Username = $Account.Username
$Address = $Account.Address
$Password = $Account.Password
$PlatformID = $Account.Platform
$Safe = $Account.Safe

$XML="{
  ""name"": ""Database-$PlatformID-$UserName"",
  ""userName"": ""$Username"",
  ""platformId"": ""$PlatformID"",
  ""safeName"": ""$Safe"",
  ""secretType"": ""password"",
  ""secret"": ""$Password"",
  ""platformAccountProperties"":  {
                                    ""Database"":  ""$Address""
                                  },
  ""secretManagement"": {
    ""automaticManagementEnabled"": true
         }
}"

Try{Invoke-RestMethod -Uri $URLAddAccount -Method POST -ContentType "application/json" -Headers $HeaderParameters -Body $XML}
Catch

{

$StatusCode =  $_.Exception.Response.StatusCode.value__
$StatusDescription =  $_.Exception.Response.StatusDescription
$StatusMessage = $_.Exception.Message

}

###############################################################

If($StatusCode -eq '409'){

$Number = Get-Random -Minimum 1 -Maximum 100000

$UserNameMod = $Username + "_" +$Number

$XML="{
  ""name"": ""Database-$PlatformID-$UserNameMod"",
  ""userName"": ""$Username"",
  ""platformId"": ""$PlatformID"",
  ""safeName"": ""$Safe"",
  ""secretType"": ""password"",
  ""secret"": ""$Password"",
  ""platformAccountProperties"":  {
                                    ""Database"":  ""$Address""
                                  },
  ""secretManagement"": {
    ""automaticManagementEnabled"": true
         }
}"

Invoke-RestMethod -Uri $URLAddAccount -Method POST -ContentType "application/json" -Headers $HeaderParameters -Body $XML

Remove-Variable Number -Force
Remove-Variable UserNameMod -Force
Remove-Variable Duplicate -Force

}

}

Menu

}

Function CyberArk-GetAccount 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"
	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){

$AccountResult

Pause

}}

Menu

}

Function CyberArk-UpdateAccount 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){

$AccountResult

$AccountID = $AccountResult.id

} else {

$Message = [System.Windows.Forms.MessageBox]::Show("Exact $Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

}

Write-Host "

Please select attribute to modify for ""$Account"":

1. ID
2. Name
3. Address
4. username
5. Platform ID
6. Safe Name
7. Secret Type
8. Platform Account Properties
9. Secret Management

" -ForegroundColor Yellow

$SelectedAttribute = Read-Host "Selection"
$Value = Read-Host "Enter new value"

If($SelectedAttribute -eq "1"){

$XML="[{
""op"": ""replace"", 
""path"": ""/id"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "2"){

$XML="[{
""op"": ""replace"", 
""path"": ""/name"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "3"){

$XML="[{
""op"": ""replace"", 
""path"": ""/address"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "4"){

$XML="[{
""op"": ""replace"", 
""path"": ""/username"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "5"){

$XML="[{
""op"": ""replace"", 
""path"": ""/platformId"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "6"){

$XML="[{
""op"": ""replace"", 
""path"": ""/safeName"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "7"){

$XML="[{
""op"": ""replace"", 
""path"": ""/secretType"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "8"){

$XML="[{
""op"": ""replace"", 
""path"": ""/platformAccountProperties"",
""value"": ""$Value""
}]"

}

If($SelectedAttribute -eq "9"){

$XML="[{
""op"": ""replace"", 
""path"": ""/secretManagement"",
""value"": ""$Value""
}]"

}

Invoke-RestMethod -Uri $URLGetExactAccount -Method PATCH -ContentType "application/json" -Body $XML -Headers $HeaderParameters

Pause

Menu

}

Function CyberArk-ChangePassword 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountID = $AccountResult.id}

}

#####################################################

$URLChangePassword = "$MasterURL/PasswordVault/api/Accounts/$AccountID/Change"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

Try{Invoke-RestMethod -Uri $URLChangePassword -Method POST -ContentType "application/json" -Headers $HeaderParameters}

Catch

{
Write-Host "Unable to change password for $Account, please investigate..." -ForegroundColor Red
Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
Write-Host "Response:" $_.Exception.Message
Menu

}

$Message = [System.Windows.Forms.MessageBox]::Show("Password changed for $Account.", 'Attention!', 'OK')

Menu

}

Function CyberArk-ReconcilePassword 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountID = $AccountResult.id}

}

#####################################################

$URLReconcilePassword = "$MasterURL/PasswordVault/api/Accounts/$AccountID/Reconcile"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

Try{Invoke-RestMethod -Uri $URLReconcilePassword -Method POST -ContentType "application/json" -Headers $HeaderParameters}

Catch

{

$Message = [System.Windows.Forms.MessageBox]::Show("Unable to change password for $Account, please investigate.", 'Attention!', 'OK')
Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
Write-Host "Response:" $_.Exception.Message
Menu

}

$Message = [System.Windows.Forms.MessageBox]::Show("Password reconcile started for $Account.", 'Attention!', 'OK')

Menu

}

Function CyberArk-RetrievePassword 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountID = $AccountResult.id}

}

#####################################################

$URLRetrievePassword = "$MasterURL/PasswordVault/api/Accounts/$AccountID/Password/Retrieve"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

Try{$Password = Invoke-RestMethod -Uri $URLRetrievePassword -Method POST -ContentType "application/json" -Headers $HeaderParameters}

Catch{

$Message = [System.Windows.Forms.MessageBox]::Show("Unable to retrieve password for $Account in CyberArk", 'Attention!', 'OK')

Menu

}

Write-Host "$($Account): $Password" -ForegroundColor Cyan

Do{

$Option = Read-Host "Press 'C' to copy or 'M' to return to the menu"
If($Option -eq 'C'){$Password | Set-Clipboard}
If($Option -eq 'M'){Menu}

}

Until($Option -eq 'M')

################################################

}

Function CyberArk-RDP 
{

$Address = Read-Host "Please enter the computer name"
$Account = Read-Host "Please enter the account name"
$Domain = Read-Host "Please specify login domain"

$ReasonPrompt = Read-Host "Provide reason for remote desktop connection? [Y/N]"
If($ReasonPrompt -eq "N"){$Reason = ""}
If($ReasonPrompt -eq "Y"){$Reason = Read-Host "Please enter reason for remote desktop connection"}

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountID = $AccountResult.id}

}

#####################################################

$URLRetrievePassword = "$MasterURL/PasswordVault/api/Accounts/$AccountID/Password/Retrieve"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$Password = Invoke-RestMethod -Uri $URLRetrievePassword -Method POST -ContentType "application/json" -Headers $HeaderParameters

$Body = @{
	secret=$Password;
	address=$Address;
	platformId="PSMSecureConnect";
	userName="$env:USERDOMAIN\$Account"
	PSMConnectPrerequisites=@{
		Reason=$Reason;
		ConnectionComponent="PSM-RDP";
		ConnectionType="RDPFile";
			}
	extraFields=@{
		Port=3389;
		AllowMappingLocalDrives="No";
		AllowConnectToConsole="No";
		LogonDomain=$Domain;
			}
} | ConvertTo-JSON


$URLRDP = "$MasterURL/PasswordVault/api/Accounts/AdHocConnect"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$RDP = Invoke-RestMethod -Uri $URLRDP -Method POST -ContentType "application/json" -Body $Body -Headers $HeaderParameters

$RDP | Out-File "C:\Users\$env:username\Downloads\$Address.rdp"
    
Start-Process "C:\Users\$env:username\Downloads\$Address.rdp"

Remove-Item "C:\Users\$env:username\Downloads\$Address.rdp" -Force

Menu

}

Function CyberArk-StartProcess 
{

$Account = Read-Host "Enter account name"

$URLGetAccount = "$MasterURL/PasswordVault/api/Accounts?search=$Account&searchType=contains&sort=UserName"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)
	
$AccountResult = Invoke-RestMethod -Uri $URLGetAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.Count -eq 0){

$Message = [System.Windows.Forms.MessageBox]::Show("$Account not found in CyberArk, please check your search criteria.", 'Attention!', 'OK')

Menu

}

$AccountIDResults = $AccountResult.Value.ID

ForEach($AccountID in $AccountIDResults){

$URLGetExactAccount = "$MasterURL/PasswordVault/api/Accounts/$AccountID"	
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$AccountResult = Invoke-RestMethod -Uri $URLGetExactAccount -Method GET -ContentType "application/json" -Headers $HeaderParameters

If($AccountResult.userName -eq "$Account"){$AccountID = $AccountResult.id}

}

#####################################################

$URLRetrievePassword = "$MasterURL/PasswordVault/api/Accounts/$AccountID/Password/Retrieve"
$HeaderParameters = @{ }
$HeaderParameters.Add($Session)

$Password = Invoke-RestMethod -Uri $URLRetrievePassword -Method POST -ContentType "application/json" -Headers $HeaderParameters

$Explorer = New-Object System.Windows.Forms.OpenFileDialog
$Show = $Explorer.ShowDialog()
If ($Show -eq "OK")
{
$File = ($Explorer | Select FileName).FileName
$Directory = (Get-Item $File | Select DIrectory).Directory
$FileName = (Get-Item $File | Select Name).Name
}
If ($Show -ne "OK"){Menu}

$IDDomain = "$env:USERDOMAIN\$Account"

$PasswordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force

Remove-Variable Password -Force

$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $IDDomain, $PasswordSecure

Remove-Variable PasswordSecure -Force

$Path = "$Directory\$Filename"

Start-Job -Name Run -ArgumentList $Path,$Directory -ScriptBlock{Start-Process $Using:path -WorkingDirectory $Using:Directory.FullName -Verb RunAs} -Credential $Credentials

Menu

}

Function Menu{

Clear-Host

Write-Host "

Login: $Global:LoginPass

Please select an option:

1. Retrieve account details
2. Retrieve account password
3. Change or reconcile an account password
4. Update account details
5. Add single account
6. Import multiple accounts
7. Delete account
8. Retrieve account credentials and start monitored Remote Desktop session
9. Retrieve account credentials and start a process (.EXE)
0. Logff

" -ForegroundColor Yellow

$Selected = Read-Host "Selection"

If($Selected -eq "1"){CyberArk-GetAccount -Authorization$Session}
If($Selected -eq "2"){CyberArk-RetrievePassword -Authorization$Session}
If($Selected -eq "3"){

Write-Host "

Please select an option:

1. Reconcile account password
2. Change account password

" -ForegroundColor Yellow

$Selected = Read-Host "Selection"

If($Selected -eq "1"){CyberArk-ChangePassword -Authorization$Session}
If($Selected -eq "2"){CyberArk-ReconcilePassword -Authorization$Session}

}
If($Selected -eq "4"){CyberArk-UpdateAccount -Authorization$Session}
If($Selected -eq "5"){CyberArk-AddAccount -Authorization$Session}
If($Selected -eq "6"){CyberArk-BulkAddAccount -Authorization$Session}
If($Selected -eq "7"){CyberArk-DeleteAccount -Authorization$Session}
If($Selected -eq "8"){CyberArk-RDP -Authorization$Session}
If($Selected -eq "9"){CyberArk-StartProcess -Authorization$Session}
If($Selected -eq "0"){CyberArk-Logoff -Authorization$Session}

#######################################

If($Selected -ne "1" -and $Selected -ne "2" -and $Selected -ne "3" -and $Selected -ne "4" -and $Selected -ne "5" -and $Selected -ne "6" -and $Selected -ne "7" -and $Selected -ne "8" -and $Selected -ne "9" -and $Selected -ne "0"){

$Message = [System.Windows.Forms.MessageBox]::Show("Invalid option selected, please try again.", 'Attention!', 'OK')

Menu

}

}

CyberArk-Logon

Menu