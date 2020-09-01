<#
.DESCRIPTION
  The purpose of this script is to get users in Active Directory by their e-mail addresses
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2016-08-09
  Purpose/Change: Initial script development
#>

$mail = "well.ozorio@gmail.com"

Get-ADUser -Filter { EmailAddress -eq $mail } -Properties SamAccountName | Select-Object SamAccountName
