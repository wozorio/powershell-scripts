<#
.DESCRIPTION
  The purpose of this script is to back up print queues with PrintBRM.exe and copy the backed up file to a central repository
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2016-10-14
  Purpose/Change: Initial script development
#>

$PrintServerName = $env:ComputerName
$PrintServerDate = Get-Date -format yyyy-MM-dd

$OutputFolder = "C:\Temp"
$OutputFile = $OutputFolder + "\" + $PrintServerName + "-PrintQueues-" + $PrintServerDate + ".bkp"
$OutputFileNameOnly = $PrintServerName + "-PrintQueues-" + $PrintServerDate + ".bkp"

$CentralRepository = "\\<server_name>\<file_share>\"

if (Test-Path $OutputFolder) {
    Write-Host "$OutputFolder folder already exists!" 
}
else {
    New-Item $OutputFolder -type directory
}

Get-ChildItem $OutputFolder -Include *.bkp -Recurse -Force | ForEach-Object ($_) { Remove-Item $_.fullname -Force }

Start-Sleep -s 10

Invoke-Expression -command "C:\Windows\System32\spool\tools\PrintBRM.exe -B -F $OutputFile"

Start-Sleep -s 10

Invoke-Expression -command "C:\Windows\System32\robocopy.exe '$OutputFolder' '$CentralRepository' '$OutputFileNameOnly' /zb /copyall /move /r:0 /w:0 /tee /log:$OutputFolder\RoboCopy_PrintQueue_Backup.log"
