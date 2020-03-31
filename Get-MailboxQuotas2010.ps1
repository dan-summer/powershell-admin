<#
.SYNOPSIS
    Check mailboxes item size
.DESCRIPTION
    Checking exchange mailboxes storage qoutas
.EXAMPLE
    .\Get-MailboxQuotas2010.ps1
.NOTES
    Checking mailbox quotas and sending e-mail with a log-file in attachment
    Applicable for Exchange Server 2010
#>

$ExchSession=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://sr-exch01/PowerShell/ -Authentication Kerberos
Import-PSSession $ExchSession -AllowClobber -DisableNameChecking

$OutDate=Get-Date -uformat "%Y.%m.%d"

$MailStat=Get-MailboxStatistics -Server sr-exch01 | Where-Object {($_.StorageLimitStatus -eq 'ProhibitSend') -or ($_.StorageLimitStatus -eq 'MailboxDisabled')} |
                                                Select-Object displayname, storagelimitstatus, totalitemsize, database, lastlogontime
$Path="C:\temp\$outdate - QuotasLog.csv"

$MailStat | Sort-Object DisplayName | Export-Csv $Path -notype -Delimiter ";" -encoding UTF8

$CountMsk=($MailStat | Where-Object {$_.DataBase -ne "UserFil_db"} | Measure-Object).Count

$CountFil=($MailStat | Where-Object {$_.DataBase -ne "UserMSK_db"} | Measure-Object).Count

$ditmail= "dit@somedomain.ru"

if ($CountMsk -eq 0 -and $CountFil -eq 0)
{
    Send-MailMessage -SmtpServer mail -to $ditmail -from mailquotas@skgelios.ru -subject "Overloaded mailboxes" -BodyAsHtml "<font size=4 face=Calibri>Number of overloaded mailboxes <b>(Msk)</b>: <font color=red>$CountMsk</font> 
    <p>Number of overloaded mailboxes <b>(Fil)</b>: <font color=red>$CountFil</font></font></p>" -Encoding UTF8
}    
else
{
    Send-MailMessage -SmtpServer mail -to $ditmail -from mailquotas@skgelios.ru -subject "Overloaded mailboxes" -BodyAsHtml "<font size=4 face=Calibri>Number of overloaded mailboxes <b>(Msk)</b>: <font color=red>$CountMsk</font> 
    <p>Number of overloaded mailboxes <b>(Fil)</b>: <font color=red>$CountFil</font></font></p>" -Encoding UTF8 -Attachments $Path
}
Remove-Item "C:\temp\* - QuotasLog.csv*"

#sending alert emails to all overloaded mailboxes
ForEach ($Item in $MailStat) 
{
    $DisplayName = $Item.DisplayName
    $Mailbox=Get-Mailbox $DisplayName
    $EmailAddresses = $Mailbox.PrimarySmtpAddress
    Send-MailMessage -SmtpServer mail -to $EmailAddresses -from $ditmail -subject "The mailbox is full" -body "Your mailbox is full! Sending emails is disabled!" -Encoding UTF8 -Priority High -Attachments '\\grshare\IT\Инфраструктура\Документация\Инструкции\Инструкция по очистке почты.docx'
}