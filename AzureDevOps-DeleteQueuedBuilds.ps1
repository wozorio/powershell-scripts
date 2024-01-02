<#
.DESCRIPTION
    Used to batch delete queued builds ("pipeline runs")
.NOTES
    Author:        Wellington Ozorio <well.ozorio@gmail.com>
    Creation Date: 2023-09-25
    Arguments:     PersonalAccessToken OrganizationName ProjectName [ApiVersion]
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PersonalAccessToken,

    [Parameter(Mandatory = $true)]
    [string]$OrganizationName,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [string]$ApiVersion = "7.1-preview.7"
)

$NotStartedBuildsUri = "https://dev.azure.com/$OrganizationName/$ProjectName/_apis/build/builds?statusFilter=notStarted&api-version=$ApiVersion"
$Base64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PersonalAccessToken"))
$Headers = @{authorization = "Basic $Base64Pat" }

try {
    $QueuedBuilds = (Invoke-RestMethod -Uri $NotStartedBuildsUri -Method GET -ContentType "application/json" -Headers $Headers).value
}
catch {
    Write-Output "ERROR: Failed fetching list of queued builds"
    Throw $_.Exception
}

if (!$QueuedBuilds) {
    Write-Output "INFO: No queued builds found to be deleted"
    exit 0
}

ForEach ($Build in $QueuedBuilds) {
    try {
        Write-Output "WARN: Deleting $($Build.url) queued build"
        Invoke-RestMethod `
            -Uri "https://dev.azure.com/$OrganizationName/$ProjectName/_apis/build/builds/$($Build.id)?api-version=$ApiVersion" `
            -Method DELETE `
            -ContentType "application/json" `
            -Headers $Headers
    }
    catch {
        Write-Output "ERROR: Failed deleting $($Build.url) queued build"
        Throw $_.Exception
    }
}
