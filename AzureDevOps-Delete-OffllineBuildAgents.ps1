<#
.DESCRIPTION
  Used to batch delete offline build agents from a specified agent pool
.NOTES
  Version:       0.1.0
  Author:        Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date: 2023-09-25
  Arguments:     personalAccessToken organizationName agentPoolName [apiVersion]
#>

param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$personalAccessToken,

  [Parameter(Mandatory = $true)]
  [string]$organizationName,

  [Parameter(Mandatory = $true)]
  [string]$agentPoolName,

  [Parameter(Mandatory = $false)]
  [string]$apiVersion = '7.2-preview.1'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$agentPoolsUri = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools?api-version=$($apiVersion)"
$base64Pat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$personalAccessToken"))
$header = @{Authorization = "Basic $base64Pat" }

try {
  $agentPools = (Invoke-RestMethod -Uri $agentPoolsUri -Method GET -ContentType "application/json" -Headers $header).value
}
catch {
  throw $_.Exception
}

if (!$agentPools) {
  Write-Output "No Pools named $($agentPoolName) found in Organization $($organizationName)"
  exit 1
}

$poolId = ($agentPools | Where-Object { $_.Name -eq $agentPoolName }).id
$agentsUri = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools/$($poolId)/agents?api-version=$($apiVersion)"
$agents = (Invoke-RestMethod -Uri $agentsUri -Method GET -Headers $header).value

if (!$agents) {
  Write-Output "ERROR: No agent found in $($agentPoolName) agent pool for $($organizationName) organization"
  exit 1
}

$agents | Where-Object { $_.status -eq 'offline' } | ForEach-Object {
  Write-Output "WARN: Removing $($_.name) agent from $($agentPoolName) agent pool in $($organizationName) organization"
  Invoke-RestMethod `
    -Uri https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools/$($_.id)/agents/$($agent)?api-version=$($apiVersion) `
    -Method DELETE `
    -ContentType "application/json" `
    -Headers $header
}
