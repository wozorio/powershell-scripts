<#
.DESCRIPTION
  Used to batch delete offline build agents from a specified agent pool
.NOTES
  Author:        Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date: 2023-09-25
  Arguments:     personalAccessToken organizationName agentPoolName [apiVersion]
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$personalAccessToken,

    [Parameter(Mandatory = $true)]
    [string]$organizationName,

    [Parameter(Mandatory = $true)]
    [string]$agentPoolName,

    [Parameter(Mandatory = $false)]
    [string]$apiVersion = '7.2-preview.1'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$agentPoolsUri = "https://dev.azure.com/$organizationName/_apis/distributedtask/pools?api-version=$apiVersion"
$base64Pat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$personalAccessToken"))
$headers = @{Authorization = "Basic $base64Pat" }

try {
    $agentPool = (Invoke-RestMethod `
            -Uri $agentPoolsUri `
            -Method GET -ContentType "application/json" `
            -Headers $headers).value | Where-Object { $_.name -eq $agentPoolName }
}
catch {
    Write-Output "ERROR: Failed fetching $agentPoolName agent pool properties"
    Throw "Exception: $_.Exception"
}

if (!$agentPool) {
    Throw "ERROR: $agentPoolName agent pool not found in $organizationName organization"
}

$poolId = ($agentPool | Where-Object { $_.Name -eq $agentPoolName }).id
$agentsUri = "https://dev.azure.com/$organizationName/_apis/distributedtask/pools/$poolId/agents?api-version=$apiVersion"

try {
    $offlineAgents = (Invoke-RestMethod -Uri $agentsUri -Method GET -Headers $headers).value | Where-Object { $_.status -eq 'offline' }
}
catch {
    Write-Output "ERROR: List of offline agents could not be fetched"
    Throw "Exception: $_.Exception"
}

if (!$offlineAgents) {
    Write-Output "INFO: No offline agents found in $agentPoolName agent pool"
    exit 0
}

$offlineAgents | ForEach-Object {
    try {
        Write-Output "WARN: Deleting $($_.name) offline agent from $agentPoolName agent pool in $organizationName organization"
        Invoke-RestMethod `
            -Uri "https://dev.azure.com/$organizationName/_apis/distributedtask/pools/$poolId/agents/$($_.id)?api-version=$apiVersion" `
            -Method DELETE `
            -ContentType "application/json" `
            -Headers $headers
    }
    catch {
        Write-Output "ERROR: Failed deleting $($_.name) offline agent from $agentPoolName agent pool in $organizationName organization"
        Throw "Exception: $_.Exception"
    }
}
