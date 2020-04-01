<#
.SYNOPSIS
    Change admins passwords
.DESCRIPTION
    Changing local administrator passwords on computers outside the domain
.EXAMPLE
    .\Change-LocAdminPass.ps1
#>

Function Get-input
{
    do
    {
        $query=Read-Host "Input C - to continue, Q - for exit"
        if ($query -eq "q")
        {
            Exit
        }
        elseif ($query -eq "c")
        {
            Continue
        }
    }
    until ($query -eq "q" -or $query -eq "c")
}
do
{
    $secPassword = Read-Host "Enter new password" -AsSecureString
    $BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPassword)
    $newPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)
    
    $confirmPassword = Read-Host "Confirm new password" -AsSecureString
    $BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)
    $confNewPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

    [regex]$regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\w\s]).{6,}"
    
    if ($newPassword -cne $confNewPassword)
    {
        Clear-Host
        Write-Host "Passwords don't match!" -ForegroundColor Yellow      
        Get-Input
    }
    elseif ($confNewPassword -cnotmatch $regex)
    {
        Clear-Host
        Write-Host "The password does not meet the policy requirements. Check the minimum password length and complexity." -ForegroundColor Yellow
        Get-Input
    }
}
until ($newPassword -ceq $confNewPassword -and $confNewPassword -cmatch $regex)

$disabled = 0x0002

$notOnline=@()

Import-Module activedirectory
Clear-Host
Write-Host "Get list of AD computers..."
$ComputersList = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "OU=someOU, DC=someDomain, DC=RU"
    
Clear-Host
Write-Host "Check the availability of computers..."

ForEach ($computerName in $ComputersList)         
{
    $ComputerName = $ComputerName.name
    
    if (Test-Connection $computerName -Count 1 -ErrorAction SilentlyContinue)
    {
        $locadmin=[adsi]"WinNT://$computerName/Administrator"
        $flag=$locadmin.UserFlags.Value -band $disabled

        if ($flag -eq $false) #-as [bool]
        {
            $locadmin.setpassword($confNewPassword)
            $locadmin.setinfo()
        }      
        else
        {
            $locadmin.put("userflags", $locadmin.UserFlags.Value -bxor $disabled)
            $locadmin.setpassword($confNewPassword)     
            $locadmin.setinfo()
        }
    }     
    else 
    {
        $obj = New-Object -TypeName psobject     
        $obj | Add-Member -MemberType NoteProperty -Name "unreacheble computers" -Value $computerName     
        $notOnline+=$obj
    }                    
}        
if ($notOnline -ne $null)
{
    $path = 'C:\TEMP\UnreachebleComputers.csv'
    $notOnline | Export-Csv $path -Encoding UTF8 -NoTypeInformation
    Clear-Host
    Write-Host "List of unreacheble computers:" -NoNewline 
    Write-Host `0"$path" -ForegroundColor Cyan  
    Read-Host "Press Enter, to Exit"
}
else 
{
    Clear-Host
    Write-Host "Passwords changed successfully" -ForegroundColor Cyan
    Read-Host "Press Enter, to Exit"       
}
