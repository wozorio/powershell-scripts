<#
.DESCRIPTION
    Used to batch delete offline build agents from a specified agent pool
.NOTES
    Author:        Wellington Ozorio <well.ozorio@gmail.com>
    Creation Date: 2023-09-25
    Arguments:     PersonalAccessToken OrganizationName AgentPoolName [ApiVersion]
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PersonalAccessToken,

    [Parameter(Mandatory = $true)]
    [string]$OrganizationName,

    [Parameter(Mandatory = $true)]
    [string]$AgentPoolName,

    [Parameter(Mandatory = $false)]
    [string]$ApiVersion = "7.2-preview.1"
)

$AgentPoolsUri = "https://dev.azure.com/$OrganizationName/_apis/distributedtask/pools?api-version=$ApiVersion"
$Base64Pat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PersonalAccessToken"))
$Headers = @{Authorization = "Basic $Base64Pat" }

try {
    $AgentPool = (Invoke-RestMethod `
            -Uri $AgentPoolsUri `
            -Method GET -ContentType "application/json" `
            -Headers $Headers).value | Where-Object { $_.name -eq $AgentPoolName }
}
catch {
    Write-Output "ERROR: Failed fetching $AgentPoolName agent pool properties"
    Throw $_.Exception
}

if (!$AgentPool) {
    Throw "ERROR: $AgentPoolName agent pool not found in $OrganizationName organization"
}

$PoolId = ($AgentPool | Where-Object { $_.Name -eq $AgentPoolName }).id
$AgentsUri = "https://dev.azure.com/$OrganizationName/_apis/distributedtask/pools/$PoolId/agents?api-version=$ApiVersion"

try {
    $OfflineAgents = (Invoke-RestMethod -Uri $AgentsUri -Method GET -Headers $Headers).value | Where-Object { $_.status -eq "offline" }
}
catch {
    Write-Output "ERROR: List of offline agents could not be fetched"
    Throw $_.Exception
}

if (!$OfflineAgents) {
    Write-Output "INFO: No offline agents found in $AgentPoolName agent pool"
    exit 0
}

$OfflineAgents | ForEach-Object {
    try {
        Write-Output "WARN: Deleting $($_.name) offline agent from $AgentPoolName agent pool in $OrganizationName organization"
        Invoke-RestMethod `
            -Uri "https://dev.azure.com/$OrganizationName/_apis/distributedtask/pools/$PoolId/agents/$($_.id)?api-version=$ApiVersion" `
            -Method DELETE `
            -ContentType "application/json" `
            -Headers $Headers
    }
    catch {
        Write-Output "ERROR: Failed deleting $($_.name) offline agent from $AgentPoolName agent pool in $OrganizationName organization"
        Throw $_.Exception
    }
}
