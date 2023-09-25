<#
.DESCRIPTION
  Used to batch delete queued builds ("pipeline runs")
.NOTES
  Version:       0.1.0
  Author:        Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date: 2023-09-25
  Arguments:     personalAccessToken organizationName projectName [apiVersion]
#>

param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
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
$header = @{authorization = "Basic $base64Pat" }

try {
  $buildsToCancel = (Invoke-RestMethod -Uri $notStartedBuildsUri -Method GET -ContentType "application/json" -Headers $header).value
}
catch {
  throw $_.Exception
}

if (!$buildsToCancel) {
  Write-Output "INFO: No queued builds found to be cancelled"
  exit 0
}

ForEach ($build in $buildsToCancel) {
  try {
    Write-Output "WARN: Deleting build $buildUri"
    Invoke-RestMethod `
      -Uri "https://dev.azure.com/$organizationName/$projectName/_apis/build/builds/$($build.id)?api-version=$apiVersion" `
      -Method DELETE `
      -ContentType "application/json" `
      -Headers $header
  }
  catch {
    Throw $_.Exception
  }
}
