<#
.SYNOPSIS
    Grant mailbox access
.DESCRIPTION
    Granting mailbox full access and send as permissions
.EXAMPLE
    .\Grant-MailboxAccess.ps1
.NOTES
    Input supports multiple comma separated values
#>

$ExchSession=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://sr-exch01/PowerShell/ -Authentication Kerberos
Import-PSSession $ExchSession -AllowClobber -DisableNameChecking

$Array1 = Read-Host `n"Enter mailbox(es) name(s)"
$MailArray = $Array1 -split ", "

$Array2 = Read-Host "Enter user(s) name(s)"
$UserArray = $Array2 -split ", "

ForEach ($Mailbox in $MailArray) 
{
    foreach ($User in $UserArray) 
    {
        Add-MailboxPermission -Identity $Mailbox -User "domain\$User" -AccessRights fullaccess
        Add-ADPermission -Identity $Mailbox -User "domain\$User" -ExtendedRights send-as
    }
}
Read-Host "Press Enter to exit"