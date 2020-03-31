<#
.SYNOPSIS
    List inactive AD users
.DESCRIPTION
    Listing inactive users from ActiveDirectory to CSV file
.EXAMPLE
    .\Get-InactiveADUsers.ps1
.NOTES
    Listing inactive users for a period 90 days to path c:\temp\InactiveADUsers.csv and sending email with number of counting
#>

Import-Module activedirectory

$adusers=Get-ADUser -SearchBase 'DC=someDomain,DC=ru' -SearchScope Subtree -filter {Enabled -eq $true} -Properties LastLogonTimeStamp, WhenCreated | 
    
            Select-Object Name, DistinguishedName, @{Name="LastLogon"; Expression={[datetime]::FromFileTime($_.Lastlogontimestamp)}}, WhenCreated | 
   
                Where-Object {$_.Lastlogon -le (Get-Date).AddDays(-90) -and $_.Lastlogon -gt (Get-Date).AddYears(-5)} | Sort-Object LastLogon     
                    
$adusers | Export-Csv -Path C:\TEMP\InactiveADUsers.csv -Delimiter ";" -Encoding UTF8 -NoType

$path='C:\TEMP\InactiveADUsers.csv'

if ($adusers -eq $null)
{
    Send-MailMessage -SmtpServer grmt -to dit@somedomain.ru -from adusers@somedomain.ru -subject "Inactive AD Users" -BodyAsHtml "<font size=4 face=Calibri>Number of inactive accounts for 90 days: <font color=red>$($adusers.count)</font></font>" -Encoding UTF8
}
else
{
    Send-MailMessage -SmtpServer grmt -to dit@somedomain.ru -from adusers@somedomain.ru -subject "Inactive AD Users" -BodyAsHtml "<font size=4 face=Calibri>Number of inactive accounts for 90 days: <font color=red>$($adusers.count)</font></font>" -Encoding UTF8 -Attachments $path
}
Remove-Item $path