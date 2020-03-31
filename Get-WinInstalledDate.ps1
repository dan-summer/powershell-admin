<#
.SYNOPSIS
    Get date of Windows instalation
.DESCRIPTION
    Getting date of Windows instalation
.EXAMPLE
    .\Get-WinInstalledDate.ps1
.NOTES
    Output Win dates to path C:\TEMP\WinInstalledDate.csv
#>

Import-Module activedirectory

$Computers = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "OU=someOU, DC=someDomain, DC=ru"

$WinDateArray=@()

ForEach ($Computer in $Computers)
{
    if (Test-Connection -Count 1 $computer.dnshostname -ErrorAction SilentlyContinue) 
    {
        $Win = Get-WmiObject win32_operatingsystem -ComputerName $computer.dnshostname
     
        $Date = $Win.ConvertToDateTime($Win.InstallDate) 
     
        $Obj = New-Object -TypeName PSObject

        $Obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.Name

        $Obj | Add-Member -MemberType NoteProperty -Name InstalledDate -Value $Date

        $WinDateArray+=$Obj 
    }
}

$WinDateArray | Sort-Object InstalledDate | Export-Csv C:\TEMP\WinInstalledDate.csv -NoType -Delimiter ";" -Encoding UTF8