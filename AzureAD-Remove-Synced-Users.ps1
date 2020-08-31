<#
.DESCRIPTION
  The purpose of this script is to delete users that were synchronized from an on-premises Domain Controller to Azure AD via Azure AD Connect
.PARAMETER searchBase
  The distinguished name of the OU where the total number of users should be calculated
.OUTPUTS
  The results are displayed on the console
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2019-02-07
  Purpose/Change: Initial script development
  #---------------------------------------------------------[IMPORTANT NOTICE]--------------------------------------------------------
    Before running this script, ensure the following actions have been taken in advance:
    - Uninstall Azure AD Connect
    - Disable Sync through PowerShell: Set-MsolDirSyncEnabled -EnableDirSync $false
    - Wait until the value of the Source attribute of the synced users on Azure Portal is changed from 'Windows Server AD' to 'Azure Active Directory'
  #---------------------------------------------------------------------------------------------------------------------------------
#>

# Sign in to Azure AD Subscription
Connect-AzureAD

# Gather list of Synced Users to be Deleted (only synced Users will have the ImmutableId attribute populated)
$SyncedUsers = Get-AzureADUser -All $true | Where-Object { $_.ImmutableId -ne $null }

# Deletes users gathered in the previous step
ForEach ($SyncedUser in $SyncedUsers) {
    $SyncedUserObjectId = $SyncedUser.ObjectId
    $SyncedUserUPN = $SyncedUser.UserPrincipalName

    Write-Host "Processing deletion of $SyncedUserUPN"
    Remove-AzureADUser -ObjectId $SyncedUserObjectId
}
