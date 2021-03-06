﻿<#
.SYNOPSIS
    List AD users
.DESCRIPTION
    Listing active users from ActiveDirectory to CSV file
.EXAMPLE
    .\Get-ActiveADUsers.ps1
.NOTES
    Listing includes active users with email adresses excludes some service accounts
#>

Import-Module activedirectory

$OutDate = Get-Date -uformat "%Y%m%d"

$OU = Get-ADUser -Filter {(mail -ne "null") -and (Enabled -eq 'True')} -SearchBase 'OU=someOU,DC=someDomain,DC=ru' -SearchScope Subtree -Properties displayName, mail, telephoneNumber, department, title | 
Where-Object {$_.displayName    -ne "test test" -and $_.SamAccountName -ne "krylov"} |
select-object -property @{Name = "Name";       Expression = {$_.displayName;}}, 
                        @{Name = "Mail";      Expression = {$_.Mail;}}, 
                        @{Name = "Phone";   Expression = {$_.telephoneNumber;}}, 
                        @{Name = "Department";     Expression = {$_.department;}}, 
                        @{Name = "Position"; Expression = {$_.title;}}

                     
$Path="C:\Temp\$OutDate - guide.csv"

$OU | Sort-Object "Name" | Export-Csv $Path -notype -Delimiter ";" -encoding "unicode" 

Write-Host "Done, $Path" -ForegroundColor yellow

Read-Host "Press Enter to Exit"
