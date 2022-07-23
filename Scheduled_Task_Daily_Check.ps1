$To = ""
$From = ""
$Server = ""
$Port = ""

$TaskName = ""
$TaskResult = (Get-ScheduledTaskInfo -TaskPath \ -TaskName $TaskName).LastTaskResult
$TaskRaw = Get-ScheduledTaskInfo -TaskPath \ -TaskName $TaskName
$TaskInfo = $TaskRaw | Out-String

If($TaskResult -eq "0"){$Subject = ""}
If($TaskResult -ne "0"){$Subject = ""}

Send-MailMessage -To $To -From $From -Subject $Subject -Body $TaskInfo -SmtpServer $Server -Port $Port -Verbose