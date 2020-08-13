<#
.DESCRIPTION
  The purpose of this script is to get timestamps of all computers in the domain that have NOT logged in since after specified date
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2016-04-23
  Purpose/Change: Initial script development
#>

$DaysInactive = 90 
$time = (Get-Date).Adddays( - ($DaysInactive))

# Get all AD computers with lastLogonTimestamp less than our time
Get-ADComputer -Filter { LastLogonTimeStamp -lt $time } -Properties LastLogonTimeStamp |

# Output hostname and lastLogonTimestamp into CSV
Select-Object Name, @{Name = "Stamp"; Expression = { [DateTime]::FromFileTime($_.lastLogonTimestamp) } } | Export-Csv ADComputers.csv -notypeinformation
