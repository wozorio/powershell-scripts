<#
.DESCRIPTION
  The purpose of this script is to run queries against a SQL database using sqlcmd, export the results to a TXT file and compress it.
  It assumes that a file called "SQLServer-Run-SQLQuery.sql" with the desired SQL query exists in the same directory where the script is located.
.PARAMETER sqlServerName
  The name of the SQL server to connect to
.PARAMETER databaseName
  The name of the SQL database to connect to
.PARAMETER databaseUserName
  The user with permissions over the SQL database
.PARAMETER databaseUserPassword
  The password of the user with permissions over the SQL database
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2019-10-29
  Purpose/Change: Initial script development
.EXAMPLE
  .\SQLServer-Run-SQLQuery.ps1 -sqlServerName <sql_server_name> `
    -databaseName <sql_database_name> `
    -databaseUserName <sql_database_username> `
    -databaseUserPassword <sql_database_username_password>
#>

# Set parameters
[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [String]$sqlServerName,
  [Parameter(Mandatory)]
  [String]$databaseName,
  [Parameter(Mandatory)]
  [String]$databaseUserName,
  [Parameter(Mandatory)]
  [String]$databaseUserPassword
)

# Set variables
$sqlStatement = "SQLServer-Run-SQLQuery.sql"
$timestamp = Get-Date -Format yyyy-MM-dd-HH-mm
$sqlOutputFile = $databaseName + "-" + $timestamp + "-" + "SQL-QUERY-RESULT.txt"
$sqlOutputFileCompressed = $databaseName + "-" + $timestamp + "-" + "SQL-QUERY-RESULT.zip"
$outputDirectory = "output"

# Create an output folder in the current directory if it does not exist
try {
  If (!(Test-Path $outputDirectory)) {
    New-Item $outputDirectory -ItemType Directory
  }
  else {
    Write-Host "$outputDirectory folder already exists. Skipping folder creation."
  }
}
catch {
  Write-Host "ERROR: Failed to create an output folder!"
}

# Run the SQL statement and save the output to a TXT file
try {
  sqlcmd -S tcp:$sqlServerName `
    -d $databaseName `
    -U $databaseUserName `
    -P $databaseUserPassword `
    -i $sqlStatement `
    -o $outputDirectory\$sqlOutputFile

}
catch {
  Write-Host "ERROR: Failed to export the results of the SQL query!"
}

# Compress the TXT output file
try {
  Compress-Archive -Path output\$sqlOutputFile -CompressionLevel Optimal -DestinationPath $outputDirectory\$sqlOutputFileCompressed
  # Delete the TXT output file if it was already compressed
  If (Test-Path $outputDirectory\$sqlOutputFileCompressed) {
    Remove-Item $outputDirectory\$sqlOutputFile -Force
  }
}
catch {
  Write-Host "ERROR: Failed to compress the TXT output file!"
}
