<#
.DESCRIPTION
  The purpose of this script is to count the total number of users in an OU (Organizational Unit) using the .NET API System.DirectoryServices.Protocols (S.DS.P).
  Unlike ADSI objects, S.DS.P interacts directly with the LDAP protocol without the underlying COM layer which makes it more robust and powerful.
.PARAMETER searchBase
  The distinguished name of the OU where the total number of users should be calculated
.OUTPUTS
  The results are displayed on the console
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2020-08-04
  Purpose/Change: Initial script development

  #---------------------------------------------------------[PREREQUISITES]--------------------------------------------------------
  This script uses an open-source module called S.DS.P which is stored in the Modules folder in this repo. Therefore, please make
  sure the folder S.DS.P in the Modules folder is copied to one of the following locations on the machine where the script will
  be executed:
  
  "C:\Users\<USERNAME>\Documents\WindowsPowerShell\Modules\"
  "C:\Program Files\WindowsPowerShell\Modules\"

  Use the first path if you want the module to be available for a specific user. Use the second path to make the module available for all users.
  For further information about the S.DS.P module, visit: https://github.com/jformacek/S.DS.P
  #---------------------------------------------------------------------------------------------------------------------------------

.EXAMPLE
  .\Get-ADTotalUsersCount.ps1 -searchBase "OU=USERS,DC=DOMAIN,DC=COM"
#>

# Set parameters
[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [String]$searchBase
)

Import-Module -Name S.DS.P

# Get connection to domain controller of your own domain on port 389 with current credentials
$Ldap = Get-LdapConnection

# Search for disabled users
$disabledUsers = (Find-LdapObject `
    -LdapConnection $Ldap `
    -PageSize 1000 `
    -SearchFilter:"(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))" `
    -SearchBase:$searchBase).count

# Search for enabled users
$enabledUsers = (Find-LdapObject `
    -LdapConnection $Ldap `
    -PageSize 1000 `
    -SearchFilter:"(&(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2)))" `
    -SearchBase:$searchBase).count

$totalUsersCount = $enabledUsers + $disabledUsers

Write-Host "Enabled users:  $enabledUsers"
Write-Host "Disabled users: $disabledUsers"
Write-Host "Total users:    $totalUsersCount"
