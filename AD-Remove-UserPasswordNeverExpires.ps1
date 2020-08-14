<#
.DESCRIPTION
  The purpose of this script is to remove the "PasswordNeverExpires" flag from user accounts in Active Directory
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2016-11-04
  Purpose/Change: Initial script development
#>

ForEach ($User in Get-Content "Users.txt") {
    Write-Host "Removing Password Never Expires flag from: $User"
    Set-ADUser -Identity $User -PasswordNeverExpires $false
}

Write-Host "PasswordNeverExpires flag has been successfully removed from all targeted users"
