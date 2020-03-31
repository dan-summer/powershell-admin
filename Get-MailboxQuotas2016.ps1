<#
.SYNOPSIS
    Check mailboxes item size on EXchange 2016
.DESCRIPTION
    Checking exchange mailboxes storage qoutas on Exchange 2016
.EXAMPLE
    .\Get-MailboxQuotas2016.ps1
.NOTES
    Checking mailbox quotas and sending e-mail with a log-file in attachment
    Applicable for Exchange Server 2016
    ScriptVersion: 2.0
#>

Add-PSSnapin -Name 'Microsoft.Exchange.Management.PowerShell.SnapIn'

$mailsMskDb = Get-Mailbox -Server sr-exch01 | Where-Object {$_.UseDatabaseQuotaDefaults -eq $true} | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize, DatabaseProhibitSendQuota, DatabaseProhibitSendReceiveQuota, DataBase, LastLogonTime
$mailsFilDb = Get-Mailbox -Server sr-exch02 | Where-Object {$_.UseDatabaseQuotaDefaults -eq $true} | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize, DatabaseProhibitSendQuota, DatabaseProhibitSendReceiveQuota, DataBase, LastLogonTime
$mailsDb = $mailsMskDb + $mailsFilDb

$mailsDbQUota = $mailsDb | Where-Object {$_.TotalItemSize.Value -ge $_.DatabaseProhibitSendQuota.Value -or $_.TotalItemSize.Value -ge $_.DatabaseProhibitSendReceiveQuota.Value} | Select-Object DisplayName, TotalItemSize, DatabaseProhibitSendQuota, DatabaseProhibitSendReceiveQuota, DataBase, LastLogonTime
                                                                                                                                                                                                                                                                                         
$arrayMailsDb=@()
foreach ($mailbox in $mailsDbQUota)
{
    $obj = New-Object -TypeName PsObject
    $obj | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $mailbox.DisplayName 
    if ($mailbox.TotalItemSize.Value -ge $mailbox.DatabaseProhibitSendQuota.Value -and $mailbox.TotalItemSize.Value -lt $mailbox.DatabaseProhibitSendReceiveQuota.Value)
    {
        $obj | Add-Member -MemberType NoteProperty -Name 'StorageLimitStatus' -Value 'ProhibitSend' 
    }
    elseif ($mailbox.TotalItemSize.Value -ge $mailbox.DatabaseProhibitSendReceiveQuota.Value)
    {
        $obj | Add-Member -MemberType NoteProperty -Name 'StorageLimitStatus' -Value 'MailboxDisabled' 
    }
    $obj | Add-Member -MemberType NoteProperty -Name 'TotalItemSize' -Value $mailbox.TotalItemSize
    $obj | Add-Member -MemberType NoteProperty -Name 'DataBase' -Value $mailbox.DataBase  
    $obj | Add-Member -MemberType NoteProperty -Name 'LastLogonTime' -Value $mailbox.LastLogonTime
    $arrayMailsDb+=$obj
}

$mailsMsk = Get-Mailbox -Server sr-exch01 | Where-Object {$_.UseDatabaseQuotaDefaults -eq $false}
$mailsMskStat = $mailsMsk | Get-MailboxStatistics
$mailsFil = Get-Mailbox -Server sr-exch02 | Where-Object {$_.UseDatabaseQuotaDefaults -eq $false}
$mailsFilStat = $mailsFil | Get-MailboxStatistics

$arrayMailsMsk=@()
foreach ($mailbox1 in $mailsMsk)
{
    $obj1 = New-Object -TypeName PsObject
    $obj1 | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $mailbox1.DisplayName
    $obj1 | Add-Member -MemberType NoteProperty -Name 'TotalItemSize' -Value ($mailsMskStat | Where-Object {$_.DisplayName -eq $mailbox1.DisplayName}).TotalItemSize
    $obj1 | Add-Member -MemberType NoteProperty -Name 'ProhibitSendQuota' -Value $mailbox1.ProhibitSendQuota
    $obj1 | Add-Member -MemberType NoteProperty -Name 'ProhibitSendReceiveQuota' -Value $mailbox1.ProhibitSendReceiveQuota
    $obj1 | Add-Member -MemberType NoteProperty -Name 'DataBase' -Value $mailbox1.Database
    $obj1 | Add-Member -MemberType NoteProperty -Name 'LastLogonTime' -Value ($mailsMskStat | Where-Object {$_.DisplayName -eq $mailbox1.DisplayName}).LastLogonTime
    $arrayMailsMsk+=$obj1
}
$arrayMailFil=@()
foreach ($mailbox2 in $mailsFil)
{
    $Obj2 = New-Object -TypeName PsObject
    $Obj2 | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $mailbox2.DisplayName
    $Obj2 | Add-Member -MemberType NoteProperty -Name 'TotalItemSize' -Value ($mailsFilStat | Where-Object {$_.DisplayName -eq $mailbox2.DisplayName}).TotalItemSize
    $Obj2 | Add-Member -MemberType NoteProperty -Name 'ProhibitSendQuota' -Value $mailbox2.ProhibitSendQuota
    $Obj2 | Add-Member -MemberType NoteProperty -Name 'ProhibitSendReceiveQuota' -Value $mailbox2.ProhibitSendReceiveQuota
    $obj2 | Add-Member -MemberType NoteProperty -Name 'DataBase' -Value $mailbox2.DataBase
    $obj2 | Add-Member -MemberType NoteProperty -Name 'LastLogonTime' -Value ($mailsMskStat | Where-Object {$_.DisplayName -eq $mailbox2.DisplayName}).LastLogonTime
    $arrayMailFil+=$Obj2
}
$mails = $arrayMailsMsk + $arrayMailFil

$mailsQuota = $mails | Where-Object {$_.TotalItemSize.Value -ge $_.ProhibitSendQuota.Value -or $_.TotalItemSize.Value -ge $_.ProhibitSendReceiveQuota.Value} | Select-Object DisplayName, TotalItemSize, ProhibitSendQuota, ProhibitSendReceiveQuota, DataBase, LastLogonTime

$arrayMails=@()
foreach ($mailbox3 in $mailsQuota)
{
    $obj3 = New-Object -TypeName PsObject
    $obj3 | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $mailbox3.DisplayName
    if ($mailbox3.TotalItemSize.Value -ge $mailbox3.ProhibitSendQuota.Value -and $mailbox3.TotalItemSize.Value -lt $mailbox3.ProhibitSendReceiveQuota.Value)
    {
        $obj3 | Add-Member -MemberType NoteProperty -Name 'StorageLimitStatus' -Value 'ProhibitSend' 
    }
    elseif ($mailbox3.TotalItemSize.Value -ge $mailbox3.ProhibitSendReceiveQuota.Value)
    {
        $obj3 | Add-Member -MemberType NoteProperty -Name 'StorageLimitStatus' -Value 'MailboxDisabled'
    }
    $obj3 | Add-Member -MemberType NoteProperty -Name 'TotalItemSize' -Value $mailbox3.TotalItemSize
    $obj3 | Add-Member -MemberType NoteProperty -Name 'DataBase' -Value $mailbox3.DataBase
    $obj3 | Add-Member -MemberType NoteProperty -Name 'LastLogonTime' -Value $mailbox3.LastLogonTime
    $arrayMails+=$obj3
}
$outMails = $arrayMails + $arrayMailsDb

$outDate = Get-Date -uformat "%Y.%m.%d"

$Path = "C:\temp\$outDate - QuotasLog.csv"

$outMails | Sort-Object DisplayName | Export-Csv $Path -Delimiter ";" -encoding UTF8 -NoTypeInformation

$countMsk = ($outMails | Where-Object {$_.DataBase.Name -eq "UserMsk_Db"} | Measure-Object).Count
$countFil = ($outMails | Where-Object {$_.DataBase.Name -eq "UserFil_Db"} | Measure-Object).Count

$ditMail = "dit@somedomain.ru"

if ($countMsk -eq 0 -and $countFil -eq 0)
{
    Send-MailMessage -SmtpServer mail -to $ditmail -from mailquotas@skgelios.ru -subject "Overloaded mailboxes" -BodyAsHtml "<font size=4 face=Calibri>Number of overloaded mailboxes <b>(Msk)</b>: <font color=red>$countMsk</font> 
    <p>Number of overloaded mailboxes <b>(Fil)</b>: <font color=red>$countFil</font></font></p>" -Encoding UTF8
}    
else
{
    Send-MailMessage -SmtpServer mail -to $ditmail -from mailquotas@skgelios.ru -subject "Overloaded mailboxes" -BodyAsHtml "<font size=4 face=Calibri>Number of overloaded mailboxes <b>(Msk)</b>: <font color=red>$countMsk</font> 
    <p>Number of overloaded mailboxes <b>(Fil)</b>: <font color=red>$countFil</font></font></p>" -Encoding UTF8 -Attachments $Path
}
Remove-Item "C:\temp\* - QuotasLog.csv*"