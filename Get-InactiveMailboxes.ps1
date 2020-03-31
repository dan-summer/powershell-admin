<#
.SYNOPSIS
    List inactive mailboxes
.DESCRIPTION
    Listing inactive exchange mailboxes to CSV file
.EXAMPLE
    .\Get-InactiveMailboxes.ps1
.NOTES
    Listing inactive mailboxes for a period 90 days to path c:\temp\InactiveMailboxes.csv
#>

$ExchSession=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://sr-exch01/PowerShell/ -Authentication Kerberos
Import-PSSession $ExchSession -AllowClobber -DisableNameChecking

$array=@()

ForEach ($item in Get-MailboxStatistics -server sr-exch01 | Select-Object DisplayName, LastLogonTime | Where-Object {$_.Lastlogontime -lt (get-date).AddDays(-90) -and $_.Lastlogontime -gt (Get-Date).AddYears(-5)} | Sort-Object LastLogonTime)
{
    $gm=Get-Mailbox $item.displayname | Select-Object @{Name='Displayname'; Expression={$item.DisplayName}}, DistinguishedName, @{Name='LastLogonTime'; Expression={$item.LastLogonTime}}, WhenCreated
    $array+=$gm
}
$array | Export-Csv -Path C:\TEMP\InactiveMailboxes.csv -Delimiter ";" -Encoding UTF8 -NoType