<#
.DESCRIPTION
  Used to batch delete queued builds ("pipeline runs")
.NOTES
  Author:        Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date: 2023-09-25
  Arguments:     personalAccessToken organizationName projectName [apiVersion]
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$personalAccessToken,

    [Parameter(Mandatory = $true)]
    [string]$organizationName,

    [Parameter(Mandatory = $true)]
    [string]$projectName,

    [Parameter(Mandatory = $false)]
    [string]$apiVersion = '7.1-preview.7'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$notStartedBuildsUri = "https://dev.azure.com/$organizationName/$projectName/_apis/build/builds?statusFilter=notStarted&api-version=$apiVersion"
$base64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$personalAccessToken"))
$headers = @{authorization = "Basic $base64Pat" }

try {
    $queuedBuilds = (Invoke-RestMethod -Uri $notStartedBuildsUri -Method GET -ContentType "application/json" -Headers $headers).value
}
catch {
    Write-Output "ERROR: Failed fetching list of queued builds"
    Throw $_.Exception
}

if (!$queuedBuilds) {
    Write-Output "INFO: No queued builds found to be deleted"
    exit 0
}

ForEach ($build in $queuedBuilds) {
    try {
        Write-Output "WARN: Deleting $buildUri queued build"
        Invoke-RestMethod `
            -Uri "https://dev.azure.com/$organizationName/$projectName/_apis/build/builds/$($build.id)?api-version=$apiVersion" `
            -Method DELETE `
            -ContentType "application/json" `
            -Headers $headers
    }
    catch {
        Write-Output "ERROR: Failed deleting $buildUri queued build"
        Throw $_.Exception
    }
}
