<#
.DESCRIPTION
  The purpose of this script is to list all Security Patches/Updates installed on Windows Servers and dump the results into a CSV file
.NOTES
  Version:        1.0
  Author:         Wellington Ozorio <well.ozorio@gmail.com>
  Creation Date:  2018-03-27
  Purpose/Change: Initial script development
#>

$Servers = Get-Content "servers.txt"

ForEach ($Server in $Servers) {
    $OutputCsv = $Server + "_Updates.csv"
    Write-Host Running script against the following server: $Server
    $RemoteSession = New-PSSession -ComputerName $Server
    Invoke-command -Session $RemoteSession -ScriptBlock {
        $Session = New-Object -ComObject "Microsoft.Update.Session"
        $Searcher = $Session.CreateUpdateSearcher()
        $historyCount = $Searcher.GetTotalHistoryCount()

        $UpdateHistory = $Searcher.QueryHistory(0, $historyCount)
        $KBs = @()

        ForEach ($Update in $UpdateHistory) {
            [regex]::match($Update.Title, '(KB[0-9]{6,7})').value | Where-Object { $_ -ne "" } | ForEach-Object {
                $KB = New-Object -TypeName PSObject
                $KB | Add-Member -MemberType NoteProperty -Name KB -Value $_
                $KB | Add-Member -MemberType NoteProperty -Name Date -Value $Update.Date   
                $KB | Add-Member -MemberType NoteProperty -Name Title -Value $Update.Title 
                $KB | Add-Member -MemberType NoteProperty -Name Description -Value $Update.Description
                $KBs += $KB
            }
        }
        $KBs
    } | Select-Object @{N = "Hostname"; E = { $Server } }, KB, Date, Title, Description | Export-Csv $OutputCsv -Encoding UTF8 -NoTypeInformation -Append

    Remove-PSSession -Session $RemoteSession
}
