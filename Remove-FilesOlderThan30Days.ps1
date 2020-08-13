<#
.DESCRIPTION
  The purpose of this script is to remove files older than 30 days
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2019-10-29
  Purpose/Change: Initial script development
#>

$Limit = (Get-Date).AddDays(-30)
$Path = "C:\Temp"

# Delete files older than the $Limit
Get-ChildItem -Path $Path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit } | Remove-Item -Force

# Delete any empty directories left behind after deleting old files
Get-ChildItem -Path $Path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
