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
  [string]$apiVersion = '5.1'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$agentPoolsUri = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools?api-version=$($apiVersion)"
$base64Pat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$personalAccessToken"))
$header = @{Authorization = "Basic $base64Pat" }

try {
  $agentPools = (Invoke-RestMethod -Uri $agentPoolsUri -Method 'Get' -Headers $header).value
}
catch {
  throw $_.Exception
}

if (!$agentPools) {
  Write-Output "No Pools named $($agentPoolName) found in Organization $($organizationName)"
  exit 1
}

If ($agentPools) {
  $poolId = ($agentPools | Where-Object { $_.Name -eq $agentPoolName }).id
  $agentsUri = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools/$($poolId)/agents?api-version=$($apiVersion)"
  $agents = (Invoke-RestMethod -Uri $agentsUri -Method 'Get' -Headers $header).value

  if (!$agents) {
    Write-Output "ERROR: No agent found in $($agentPoolName) agent pool for $($organizationName) organization"
    exit 1
  }

  $agentNames = ($agents | Where-Object { $_.status -eq 'Offline' }).Name
  $offlineAgents = ($agents | Where-Object { $_.status -eq 'Offline' }).id
  foreach ($agent in $offlineAgents) {
    foreach ($agent in $agentNames) {
      Write-Output "WARN: Removing $($agent) agent from $($agentPoolName) agent pool in $($organizationName) organization"
      $offlineAgentsUri = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/pools/$($poolId)/agents/$($agent)?api-version=$($apiVersion)"
      # Invoke-RestMethod -Uri $offlineAgentsUri -Method 'Delete' -Headers $header
    }
  }
}
