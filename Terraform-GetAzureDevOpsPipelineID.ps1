<#
.DESCRIPTION
    Used by Terraform external data source resource to fetch pipeline ID from the Azure DevOps Pipelines REST API
.NOTES
    Author:        Wellington Ozorio <well.ozorio@gmail.com>
    Creation Date: 2022-03-09
    Arguments:     PipelineName
#>

$JsonPayload = [Console]::In.ReadLine()
$Json = ConvertFrom-Json $JsonPayload

$PipelineName = $Json.pipelineName

# Azure DevOps Pipelines REST API reference:
# https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/list?view=azure-devops-rest-6.0
$AdoPipelinesApi = "https://dev.azure.com/bosch-ciam/skid/_apis/pipelines?api-version=6.0-preview.1"

$Pat = "$env:AZDO_PERSONAL_ACCESS_TOKEN"
$Base64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("PAT:$Pat"))
$Headers = @{authorization = "Basic $Base64Pat" }

try {
    $JsonContent = Invoke-RestMethod -Uri $AdoPipelinesApi -Method Get -ContentType "application/json" -Headers $Headers

    $PipelineId = $JsonContent.value | Where-Object { $_.name -eq "$PipelineName" }
    $PipelineId = $PipelineId.id | ConvertTo-Json

    if ($PipelineId) {
        Write-Output "{""pipeline_id"" : ""$PipelineId""}"
    }
    else {
        Throw "ERROR: failed to fetch ID of $PipelineName pipeline"
    }
}
catch {
    Throw $_
}
