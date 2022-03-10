# Execute:
# powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-ScheduledTask.ps1

[CmdletBinding()]
Param (
    [AllowNull()]
    [String]
    $ScheduledTaskName
)

$taskArr = @()
if ($ScheduledTaskName) {    
    # $apptasks = Get-ScheduledTask | where {($_.state -eq "Running" -or $_.state -eq "Ready") -and  ($_.taskname -eq $ScheduledTaskName)} | Get-ScheduledTaskInfo 
    $apptasks = Get-ScheduledTask | where {($_.taskname -eq $ScheduledTaskName)} | Get-ScheduledTaskInfo 
    foreach ($apptask in $apptasks)
    { 
        # if ($apptask.LastRunTime) {
        $Now = get-Date
        $DateDiff = New-TimeSpan -Start ($Now) -End ($apptask.LastRunTime)

        $Tasks = New-Object -TypeName PsObject
        $Tasks | Add-Member -MemberType NoteProperty -Name 'TASK' -Value  $apptask.TaskName -Force  
        $Tasks | Add-Member -MemberType NoteProperty -Name 'LASTRUN' -Value  $apptask.LastRunTime.ToString("dd.MM.yyyy hh:mm:ss") -Force   
        $Tasks | Add-Member -MemberType NoteProperty -Name 'LASTRUNRESULT' -Value  $apptask.LastTaskResult -Force 
        $Tasks | Add-Member -MemberType NoteProperty -Name 'NUMBEROFMISSEDRUNS' -Value  $apptask.NumberOfMissedRuns -Force 
        $Tasks | Add-Member -MemberType NoteProperty -Name 'DAYSFROMLASTRUN' -Value  $DateDiff.Days -Force 

        $taskArr += $Tasks         
        # }
    }  
} else {
    $apptasks = Get-ScheduledTask | where {($_.taskpath -eq "\")} | Get-ScheduledTaskInfo
    foreach ($apptask in $apptasks)
    { 
        # if ($apptask.LastRunTime) {
        $Tasks = New-Object -TypeName PsObject
        $Tasks | Add-Member -MemberType NoteProperty -Name '{#TASK}' -Value  $apptask.TaskName -Force  
        $taskArr += $Tasks 
        # } 
    } 
}

if ($taskArr) {
    $json = [pscustomobject]@{'data' = @($taskArr)} | ConvertTo-Json 
    [Console]::WriteLine($json)
}
