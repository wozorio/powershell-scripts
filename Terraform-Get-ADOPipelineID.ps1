<#
.DESCRIPTION
  Used by Terraform external data source resource to fetch pipeline ID from the Azure DevOps Pipelines REST API
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <Wellington.Ozorio@br.bosch.com>
  Creation Date:  2022-03-09
  Arguments:      pipelineName
#>

$jsonPayload = [Console]::In.ReadLine()
$json = ConvertFrom-Json $jsonPayload

$pipelineName = $json.pipelineName

# Azure DevOps Pipelines REST API reference:
# https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/list?view=azure-devops-rest-6.0
$adoPipelinesApi = "https://dev.azure.com/bosch-ciam/skid/_apis/pipelines?api-version=6.0-preview.1"

$pat = "$env:AZDO_PERSONAL_ACCESS_TOKEN"
$base64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("PAT:$pat"))
$header = @{authorization = "Basic $base64Pat" }

try {
  $jsonContent = Invoke-RestMethod -Uri $adoPipelinesApi -Method Get -ContentType "application/json" -Headers $header
    
  $pipelineId = $jsonContent.value | Where-Object { $_.name -eq "$pipelineName" }
  $pipelineId = $pipelineId.id | ConvertTo-Json

  if ($pipelineId) {
    Write-Output "{""pipeline_id"" : ""$pipelineId""}"
  }
  else {
    Throw "ERROR: failed to fetch ID of $pipelineName pipeline"
  }
}
catch {
  Throw $_
}
