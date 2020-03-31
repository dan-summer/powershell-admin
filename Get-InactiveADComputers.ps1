<#
.SYNOPSIS
    List inactive AD computers
.DESCRIPTION
    Listing inactive not disabled AD computers from ActiveDirectory to CSV file
.EXAMPLE
    .\Get-InactiveADComputers.ps1
.NOTES
    Listing inactive computers for a period 90 days to path c:\temp\InactiveADcomputers.csv
#>

Import-Module activedirectory

$adcomputers=Get-ADComputer -SearchBase 'DC=someDomain,DC=ru' -SearchScope Subtree -filter {Enabled -eq $true} -Properties LastLogonTimeStamp, WhenCreated | 
    
            Select-Object Name, DistinguishedName, @{Name="LastLogon"; Expression={[datetime]::FromFileTime($_.Lastlogontimestamp)}}, WhenCreated | 
   
                Where-Object {$_.Lastlogon -le (Get-Date).AddDays(-90) -and $_.Lastlogon -gt (Get-Date).AddYears(-5)} | Sort-Object LastLogon

$adcomputers | Export-Csv -Path C:\TEMP\InactiveADComputers.csv -Delimiter ";" -Encoding UTF8 -NoType