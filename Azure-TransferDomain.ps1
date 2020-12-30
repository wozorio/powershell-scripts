<#
.DESCRIPTION
  The purpose of this script is to transfer a domain purchased outside Azure (i.e.: GoDaddy) to Azure (App Service Domain)
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2020-12-30
  Purpose/Change: Initial script development
#>

# Change the value of the variables below according to your environment
$domainName = 'domain.com' # domain name
$resourceLocation = 'Global'
$resourceGroup = 'rg-prod-domain' # RG where the App Service Domain will be created
$ipAddress = '192.168.1.1' # user's IP address
$authCode = 'xpto123456' # authorization code obtained from the current provider (registrar) in order to transfer out the domain
$currentTime = '2020-12-30T13:55:30.6850404Z' # roughly the current time (2017-13-05T12:25:30.6850404Z)

$propertiesObject = @{
  'Consent'   = @{
    'AgreementKeys' = @("DNPA", "DNTA");
    'AgreedBy'      = $ipAddress;
    'AgreedAt'      = $currentTime;
  };
  'authCode'  = $authCode; 
  'Privacy'   = 'true';
  'autoRenew' = 'true';
}

# Create an App Service Domain and initiate the domain transfer
New-AzureRmResource `
  -ResourceName $domainName `
  -Location $resourceLocation `
  -PropertyObject $propertiesObject `
  -ResourceGroupName $resourceGroup `
  -ResourceType Microsoft.DomainRegistration/domains `
  -ApiVersion 2015-02-01 `
  -Verbose
