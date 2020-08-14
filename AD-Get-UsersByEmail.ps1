<#
.DESCRIPTION
  The purpose of this script is to get users in Active Directory by their e-mail addresses
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2016-08-09
  Purpose/Change: Initial script development
#>

ForEach ($email in Get-Content "emails.txt") {
    Get-ADUser -Filter { EmailAddress -eq $email } `
        -Properties distinguishedName, Name, SamAccountName, CN, telephoneNumber, mobile `
    | Select-Object distinguishedName, Name, SamAccountName, CN, telephoneNumber, mobile `
    | Export-Csv -Append Users.csv -NotypeInformation
}
