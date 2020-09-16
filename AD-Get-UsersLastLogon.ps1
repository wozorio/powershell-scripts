<#
.DESCRIPTION
  The purpose of this script is to get users in Active Directory who have not logged in since date ("MM.dd.yyyy HH:mm:ss")
  A CSV file called ADUsers-LastLogon-Report.csv is generated in the directory where the script is executed containing the users that match the criteria
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2020-09-11
  Purpose/Change: Initial script development
#>

$searchBase = "OU=Users,DC=CONTOSO,DC=COM"
$lastLogonDateEnd = "11.20.2019 00:00:00"

# Convert variable $lastLogonDateEnd from type String to Date
$lastLogonDateEnd = [datetime]::ParseExact($lastLogonDateEnd, "MM.dd.yyyy HH:mm:ss", $null)

# Search for users who have not logged in since $lastLogonDateEnd
Get-ADUser `
  -ResultPageSize 5 `
  -Filter { Enabled -eq $true -and LastLogonDate -lt $lastLogonDateEnd -and mail -like "*@*" } `
  -SearchBase $searchBase `
  -Properties objectSid, mail, LastLogonDate `
| Select-Object objectSid, mail, LastLogonDate `
| Export-Csv "ADUsers-LastLogon-Report.csv" -NoTypeInformation -Encoding UTF8
